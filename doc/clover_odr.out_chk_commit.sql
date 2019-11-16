CREATE OR REPLACE FUNCTION clover_odr.out_chk_commit(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 收款交接班确认 入参:thsp_code + "|" + ted + "|" + topcode + "|" + tgc; 截止时间入参格式yyyy-mm-dd hh24:mi:ss
-- 11	收费类别	西药(01)
-- 12	收费类别	中成药(02)
-- 13	收费类别	中草药(03)
-- 21	收费类别	检查费(04)
-- 22	收费类别	特殊检查费(05)
-- 23	收费类别	输氧费(06)
-- 24	收费类别	手术费(07)
-- 25	收费类别	化验费(08)
-- 26	收费类别	输血费(09)
-- 27	收费类别	诊察费(10)
-- 28	收费类别	材料费(11)
-- 29	收费类别	特殊材料费(12)
-- 31	收费类别	治疗费(13)
-- 32	收费类别	特殊治疗费(14)
-- 33	收费类别	护理费(15)
-- 34	收费类别	床位费(16)
-- 35	收费类别	取暖费(17)
-- 36	收费类别	一次性医用材料(18)
-- 91	收费类别	其他费用(19)
-- 92	收费类别	挂号费(20)
DECLARE
    tin_arrays text ARRAY;	
	thsp_code clover_odr.chk_sum.hsp_code%type;  --医院编码
	topcode clover_odr.chk_sum.chk_opcode%type;  -- 交班操作员
	tedstr text;  --截止时间
	tendtime clover_odr.chk_sum.chk_time%type;
	tstime clover_odr.chk_sum.chk_time%type;
	tseq clover_odr.chk_sum.seq%type;
	
	tchksum clover_odr.chk_sum%rowtype;  --结算汇总
	tcd1 clover_odr.chk_detail%rowtype;  --结算挂号
	tcd1b clover_odr.chk_detail%rowtype; --结算退号
	tcd2 clover_odr.chk_detail%rowtype;  --结算门诊收款
	tcd2b clover_odr.chk_detail%rowtype;  --结算门诊退款
	tcd3 clover_odr.chk_detail%rowtype;   --结算收预交金
	tcd3b clover_odr.chk_detail%rowtype;  --结算退预交金
	tcd4 clover_odr.chk_detail%rowtype;   --出院结算返款
	tcd4b clover_odr.chk_detail%rowtype;   --出院结算召回
	
	tout_str_sum text := '';
	tout_str_detail text := '';
BEGIN	
    select  string_to_array(tin_str,'|') into tin_arrays;
	thsp_code := tin_arrays[1];
	tedstr := tin_arrays[2];
	topcode := tin_arrays[3];
	SELECT opname into tchksum.opname FROM clover_md.kd99 where hsp_code=thsp_code and opcode=topcode;
	tendtime := to_timestamp(tedstr,'YYYY-MM-DD HH24:MI:SS');
	tstime := now();
	if tendtime>tstime then
	  tendtime := tstime;
	elsif tendtime< tstime - interval '2h' then
	  tendtime := tstime;
	end if;
	raise notice 'thsp_code=%,ted_str=%,topcode=%',thsp_code,tedstr,topcode;
	--查询最新的交班记录
	SELECT seq into tseq FROM clover_odr.chk_sum where hsp_code=thsp_code and opcode=topcode order by seq desc limit 1;
	raise notice 'tseq=%',tseq;
	if (tseq is null) or (tseq <=0) then  --写入初始数据,先计算明细，后计算汇总，起始时间为当前时间-365days,截止时间为传入的时间，截止时间大于当前时间按当前时间，小于当前时间2h按当前时间
	  tchksum.bd := now() - interval '365 days' ;
	  tchksum.remark := '初始化';
	  tseq := 0;
	else
	  SELECT ed into tchksum.bd FROM clover_odr.chk_sum where seq = tseq ;
	  tchksum.remark := tseq;
	end if;
	tchksum.seq := nextval('clover_odr.seq_chk_sum');
	tchksum.hsp_code := thsp_code;
	tchksum.opcode := topcode;	
	tchksum.ed := tendtime;
	tchksum.chk_time := tstime;
	tchksum.chk_opcode := topcode;
	SELECT to_char(to_number(coalesce(max(chk_flow),'00000000'),'99999999')+1,'00000000') into tchksum.chk_flow
	  FROM clover_odr.chk_sum where opcode=topcode and hsp_code=thsp_code;
	-- 计算挂号费用---reg--------------------------------------------------------------------1111111111111111111111111111-----------------------
	tcd1.seq := nextval('clover_odr.seq_chk_detail');
	tcd1.seq_chk_sum := tchksum.seq;
	tcd1.hsp_code := thsp_code;
	tcd1.opcode := topcode;
	tcd1.opname := tchksum.opname;
	tcd1.chk_type := 'reg';
	tcd1.bd := tchksum.bd;
	tcd1.ed := tchksum.ed;
	tcd1.chk_time := tstime;
	tcd1.chk_opcode := topcode;
	tcd1.trade_type := '0';
	SELECT to_char(to_number(coalesce(max(chk_flow_detail),'00000000'),'99999999')+1,'00000000') into tcd1.chk_flow_detail
	  FROM clover_odr.chk_detail where hsp_code=thsp_code and opcode=topcode;
	SELECT coalesce(count(seq),0) into tcd1.paper_num FROM clover_odr.out_reg_prn 
	WHERE prn_status<>'-1' and reg_opcode=topcode and hsp_code=thsp_code
	  and reg_time>=tchksum.bd and reg_time<tchksum.ed;
	SELECT coalesce(max(invoice_nmb),'0000000000'), coalesce(min(invoice_nmb),'0000000000'),
	    coalesce(max(flow_nmb),'0000000000'),coalesce(min(flow_nmb),'0000000000'),
		coalesce(sum(all_sum),0.00), coalesce(sum(cash_sum),0.00), coalesce(sum(pacc_sum),0.00), 
		coalesce(sum(fund_sum),0.00), coalesce(sum(fund_nh_sum),0.00), coalesce(sum(fund_commeric),0.00), 
		coalesce(sum(weixin_sum),0.00), coalesce(sum(alipay_sum),0.00), coalesce(sum(unionpay_sum),0.00), 
		coalesce(sum(check_sum),0.00), coalesce(sum(voucher_sum),0.00), coalesce(sum(spec_sum),0.00)
	into tcd1.einvoice_nmb,tcd1.binvoice_nmb,
	    tcd1.eflow,tcd1.bflow,
		tcd1.all_sum, tcd1.cash_sum, tcd1.pacc_sum,
		tcd1.fund_sum, tcd1.fund_nh_sum, tcd1.fund_commeric,
		tcd1.weixin_sum, tcd1.alipay_sum, tcd1.unionpay_sum,
		tcd1.check_sum, tcd1.voucher_sum, tcd1.spec_sum
	FROM clover_odr.cash_set
	where pay_cate='reg' and hsp_code=thsp_code 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode and all_sum>0;
	tcd1.all_sum_upper := clover_md.udf_digits2hanzi(trunc(tcd1.all_sum):: bigint)||'元'||
	 clover_md.udf_digits2hanzi(((trunc(tcd1.all_sum,1) - trunc(tcd1.all_sum))*10 ):: bigint)||'角'||
	 clover_md.udf_digits2hanzi(((trunc(tcd1.all_sum,2) - trunc(tcd1.all_sum,1))*100 ):: bigint)||'分';
	tcd1.sum01 := 0.00;
	tcd1.sum02 := 0.00;
	tcd1.sum03 := 0.00;
	tcd1.sum04 := 0.00;
	tcd1.sum05 := 0.00;
	tcd1.sum06 := 0.00;
	tcd1.sum07 := 0.00;
	tcd1.sum08 := 0.00;
	tcd1.sum09 := 0.00;
	tcd1.sum10 := 0.00;
	tcd1.sum11 := 0.00;
	tcd1.sum12 := 0.00;
	tcd1.sum13 := 0.00;
	tcd1.sum14 := 0.00;
	tcd1.sum15 := 0.00;
	tcd1.sum16 := 0.00;
	tcd1.sum17 := 0.00;
	tcd1.sum18 := 0.00; 
	tcd1.sum19 := 0.00;
	tcd1.sum20 := tcd1.all_sum;	  
	insert into clover_odr.chk_detail values (tcd1.*);
	  
	tcd1b.seq := nextval('clover_odr.seq_chk_detail');
	tcd1b.seq_chk_sum := tchksum.seq;
	tcd1b.hsp_code := thsp_code;
	tcd1b.opcode := topcode;
	tcd1b.opname := tchksum.opname;
	tcd1b.chk_type := 'reg';
	tcd1b.bd := tchksum.bd;
	tcd1b.ed := tchksum.ed;
	tcd1b.chk_time := tstime;
	tcd1b.chk_opcode := topcode;
	tcd1b.trade_type := '-1';
	SELECT to_char(to_number(coalesce(max(chk_flow_detail),'00000000'),'99999999')+1,'00000000') into tcd1b.chk_flow_detail
	  FROM clover_odr.chk_detail where hsp_code=thsp_code and opcode=topcode;
	SELECT coalesce(count(seq),0) into tcd1.paper_num FROM clover_odr.out_reg_prn 
	WHERE prn_status='-1' and reg_opcode=topcode and hsp_code=thsp_code
	  and reg_time>=tchksum.bd and reg_time<tchksum.ed;
	SELECT coalesce(max(invoice_nmb),'0000000000'), coalesce(min(invoice_nmb),'0000000000'),
	    coalesce(max(flow_nmb),'0000000000'),coalesce(min(flow_nmb),'0000000000'),
		coalesce(sum(all_sum),0.00), coalesce(sum(cash_sum),0.00), coalesce(sum(pacc_sum),0.00), 
		coalesce(sum(fund_sum),0.00), coalesce(sum(fund_nh_sum),0.00), coalesce(sum(fund_commeric),0.00), 
		coalesce(sum(weixin_sum),0.00), coalesce(sum(alipay_sum),0.00), coalesce(sum(unionpay_sum),0.00), 
		coalesce(sum(check_sum),0.00), coalesce(sum(voucher_sum),0.00), coalesce(sum(spec_sum),0.00)
	into tcd1b.einvoice_nmb,tcd1b.binvoice_nmb,
	    tcd1b.eflow,tcd1b.bflow,
		tcd1b.all_sum, tcd1b.cash_sum, tcd1b.pacc_sum,
		tcd1b.fund_sum, tcd1b.fund_nh_sum, tcd1b.fund_commeric,
		tcd1b.weixin_sum, tcd1b.alipay_sum, tcd1b.unionpay_sum,
		tcd1b.check_sum, tcd1b.voucher_sum, tcd1b.spec_sum
	FROM clover_odr.cash_set
	where pay_cate='reg' and hsp_code=thsp_code 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode and all_sum<=0;
	tcd1b.all_sum_upper := '负'||clover_md.udf_digits2hanzi(trunc(abs(tcd1b.all_sum)):: bigint)||'元'||
	 clover_md.udf_digits2hanzi(((trunc(abs(tcd1b.all_sum),1) - trunc(abs(tcd1b.all_sum)))*10 ):: bigint)||'角'||
	 clover_md.udf_digits2hanzi(((trunc(abs(tcd1b.all_sum),2) - trunc(abs(tcd1b.all_sum),1))*100 ):: bigint)||'分';
	tcd1b.sum01 := 0.00;
	tcd1b.sum02 := 0.00;
	tcd1b.sum03 := 0.00;
	tcd1b.sum04 := 0.00;
	tcd1b.sum05 := 0.00;
	tcd1b.sum06 := 0.00;
	tcd1b.sum07 := 0.00;
	tcd1b.sum08 := 0.00;
	tcd1b.sum09 := 0.00;
	tcd1b.sum10 := 0.00;
	tcd1b.sum11 := 0.00;
	tcd1b.sum12 := 0.00;
	tcd1b.sum13 := 0.00;
	tcd1b.sum14 := 0.00;
	tcd1b.sum15 := 0.00;
	tcd1b.sum16 := 0.00;
	tcd1b.sum17 := 0.00;
	tcd1b.sum18 := 0.00; 
	tcd1b.sum19 := 0.00;
	tcd1b.sum20 := tcd1b.all_sum;
	insert into clover_odr.chk_detail values (tcd1b.*);
	
	--计算门诊收款-----cash------------------------------------------------------------------22222222222222222222222222222-----------------------
	tcd2.seq := nextval('clover_odr.seq_chk_detail');
	tcd2.seq_chk_sum := tchksum.seq;
	tcd2.hsp_code := thsp_code;
	tcd2.opcode := topcode;
	tcd2.opname := tchksum.opname;
	tcd2.chk_type := 'cash';
	tcd2.bd := tchksum.bd;
	tcd2.ed := tchksum.ed;
	tcd2.chk_time := tstime;
	tcd2.chk_opcode := topcode;
	tcd2.trade_type := '0';
	SELECT to_char(to_number(coalesce(max(chk_flow_detail),'00000000'),'99999999')+1,'00000000') into tcd2.chk_flow_detail
	  FROM clover_odr.chk_detail where hsp_code=thsp_code and opcode=topcode;
	SELECT coalesce(count(seq),0) into tcd2.paper_num
	  FROM clover_odr.out_cash_prn 
	where prn_status<>'-1' and hsp_code=thsp_code and cash_opcode=topcode
	  and cash_time>=tchksum.bd and cash_time<tchksum.ed;
	SELECT coalesce(max(invoice_nmb),'0000000000'), coalesce(min(invoice_nmb),'0000000000'),
	    coalesce(max(flow_nmb),'0000000000'),coalesce(min(flow_nmb),'0000000000'),
		coalesce(sum(all_sum),0.00), coalesce(sum(cash_sum),0.00), coalesce(sum(pacc_sum),0.00), 
		coalesce(sum(fund_sum),0.00), coalesce(sum(fund_nh_sum),0.00), coalesce(sum(fund_commeric),0.00), 
		coalesce(sum(weixin_sum),0.00), coalesce(sum(alipay_sum),0.00), coalesce(sum(unionpay_sum),0.00), 
		coalesce(sum(check_sum),0.00), coalesce(sum(voucher_sum),0.00), coalesce(sum(spec_sum),0.00)
	into tcd2.einvoice_nmb,tcd2.binvoice_nmb,
	    tcd2.eflow,tcd2.bflow,
		tcd2.all_sum, tcd2.cash_sum, tcd2.pacc_sum,
		tcd2.fund_sum, tcd2.fund_nh_sum, tcd2.fund_commeric,
		tcd2.weixin_sum, tcd2.alipay_sum, tcd2.unionpay_sum,
		tcd2.check_sum, tcd2.voucher_sum, tcd2.spec_sum
	FROM clover_odr.cash_set
	where pay_cate='cash' and hsp_code=thsp_code and trade_type='0' 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	tcd2.all_sum_upper := clover_md.udf_digits2hanzi(trunc(tcd2.all_sum):: bigint)||'元'||
	  clover_md.udf_digits2hanzi(((trunc(tcd2.all_sum,1) - trunc(tcd2.all_sum))*10 ):: bigint)||'角'||
	  clover_md.udf_digits2hanzi(((trunc(tcd2.all_sum,2) - trunc(tcd2.all_sum,1))*100 ):: bigint)||'分';
	tcd2.sum01 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'11','0');
	tcd2.sum02 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'12','0');
	tcd2.sum03 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'13','0');
	tcd2.sum04 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'21','0');
	tcd2.sum05 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'22','0');
	tcd2.sum06 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'23','0');
	tcd2.sum07 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'24','0');
	tcd2.sum08 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'25','0');
	tcd2.sum09 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'26','0');
	tcd2.sum10 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'27','0');
	tcd2.sum11 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'28','0');
	tcd2.sum12 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'29','0');
	tcd2.sum13 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'31','0');
	tcd2.sum14 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'32','0');
	tcd2.sum15 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'33','0');
	tcd2.sum16 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'34','0');
	tcd2.sum17 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'35','0');
	tcd2.sum18 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'36','0');
	tcd2.sum19 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'91','0');
	tcd2.sum20 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'92','0');	
	insert into clover_odr.chk_detail values (tcd2.*);  
	
	------  
	tcd2b.seq := nextval('clover_odr.seq_chk_detail');
	tcd2b.seq_chk_sum := tchksum.seq;
	tcd2b.hsp_code := thsp_code;
	tcd2b.opcode := topcode;
	tcd2b.opname := tchksum.opname;
	tcd2b.chk_type := 'cash';
	tcd2b.bd := tchksum.bd;
	tcd2b.ed := tchksum.ed;
	tcd2b.chk_time := tstime;
	tcd2b.chk_opcode := topcode;
	tcd2b.trade_type := '-1';
	SELECT to_char(to_number(coalesce(max(chk_flow_detail),'00000000'),'99999999')+1,'00000000') into tcd2b.chk_flow_detail
	  FROM clover_odr.chk_detail where hsp_code=thsp_code and opcode=topcode;
	SELECT coalesce(count(seq),0) into tcd2b.paper_num
	  FROM clover_odr.out_cash_prn 
	where prn_status='-1' and hsp_code=thsp_code and cash_opcode=topcode
	  and cash_time>=tchksum.bd and cash_time<tchksum.ed;
	SELECT coalesce(max(invoice_nmb),'0000000000'), coalesce(min(invoice_nmb),'0000000000'),
	    coalesce(max(flow_nmb),'0000000000'),coalesce(min(flow_nmb),'0000000000'),
		coalesce(sum(all_sum),0.00), coalesce(sum(cash_sum),0.00), coalesce(sum(pacc_sum),0.00), 
		coalesce(sum(fund_sum),0.00), coalesce(sum(fund_nh_sum),0.00), coalesce(sum(fund_commeric),0.00), 
		coalesce(sum(weixin_sum),0.00), coalesce(sum(alipay_sum),0.00), coalesce(sum(unionpay_sum),0.00), 
		coalesce(sum(check_sum),0.00), coalesce(sum(voucher_sum),0.00), coalesce(sum(spec_sum),0.00)
	into tcd2b.einvoice_nmb,tcd2b.binvoice_nmb,
	    tcd2b.eflow,tcd2b.bflow,
		tcd2b.all_sum, tcd2b.cash_sum, tcd2b.pacc_sum,
		tcd2b.fund_sum, tcd2b.fund_nh_sum, tcd2b.fund_commeric,
		tcd2b.weixin_sum, tcd2b.alipay_sum, tcd2b.unionpay_sum,
		tcd2b.check_sum, tcd2b.voucher_sum, tcd2b.spec_sum
	FROM clover_odr.cash_set
	where pay_cate='cash' and hsp_code=thsp_code and trade_type='-1' 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
    tcd2b.all_sum_upper := '负'||clover_md.udf_digits2hanzi(trunc(abs(tcd2b.all_sum)):: bigint)||'元'||
	  clover_md.udf_digits2hanzi(((trunc(abs(tcd2b.all_sum),1) - trunc(abs(tcd2b.all_sum)))*10 ):: bigint)||'角'||
	  clover_md.udf_digits2hanzi(((trunc(abs(tcd2b.all_sum),2) - trunc(abs(tcd2b.all_sum),1))*100 ):: bigint)||'分';	  
    tcd2b.sum01 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'11','-1');
	tcd2b.sum02 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'12','-1');
	tcd2b.sum03 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'13','-1');
	tcd2b.sum04 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'21','-1');
	tcd2b.sum05 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'22','-1');
	tcd2b.sum06 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'23','-1');
	tcd2b.sum07 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'24','-1');
	tcd2b.sum08 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'25','-1');
	tcd2b.sum09 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'26','-1');
	tcd2b.sum10 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'27','-1');
	tcd2b.sum11 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'28','-1');
	tcd2b.sum12 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'29','-1');
	tcd2b.sum13 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'31','-1');
	tcd2b.sum14 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'32','-1');
	tcd2b.sum15 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'33','-1');
	tcd2b.sum16 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'34','-1');
	tcd2b.sum17 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'35','-1');
	tcd2b.sum18 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'36','-1');
	tcd2b.sum19 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'91','-1');
	tcd2b.sum20 := clover_odr.calc_fee_itemsum(thsp_code,topcode,tchksum.bd,tchksum.ed,'92','-1');
	
	insert into clover_odr.chk_detail values (tcd2b.*); 
	
	--计算住院预交金----deposit--------------------------------------------------------------3333333333333333333333333333-------------------------
	tcd3.seq := nextval('clover_odr.seq_chk_detail');
	tcd3.seq_chk_sum := tchksum.seq;
	tcd3.hsp_code := thsp_code;
	tcd3.opcode := topcode;
	tcd3.opname := tchksum.opname;
	tcd3.chk_type := 'deposit';
	tcd3.bd := tchksum.bd;
	tcd3.ed := tchksum.ed;
	tcd3.chk_time := tstime;
	tcd3.chk_opcode := topcode;
	tcd3.trade_type := '0';
	SELECT to_char(to_number(coalesce(max(chk_flow_detail),'00000000'),'99999999')+1,'00000000') into tcd3.chk_flow_detail
	  FROM clover_odr.chk_detail where hsp_code=thsp_code and opcode=topcode;
	--暂时把预交金张数设置为0
	tcd3.paper_num := 0;
	SELECT coalesce(max(invoice_nmb),'0000000000'), coalesce(min(invoice_nmb),'0000000000'),
	    coalesce(max(flow_nmb),'0000000000'),coalesce(min(flow_nmb),'0000000000'),
		coalesce(sum(all_sum),0.00), coalesce(sum(cash_sum),0.00), coalesce(sum(pacc_sum),0.00), 
		coalesce(sum(fund_sum),0.00), coalesce(sum(fund_nh_sum),0.00), coalesce(sum(fund_commeric),0.00), 
		coalesce(sum(weixin_sum),0.00), coalesce(sum(alipay_sum),0.00), coalesce(sum(unionpay_sum),0.00), 
		coalesce(sum(check_sum),0.00), coalesce(sum(voucher_sum),0.00), coalesce(sum(spec_sum),0.00)
	into tcd3.einvoice_nmb,tcd3.binvoice_nmb,
	    tcd3.eflow,tcd3.bflow,
		tcd3.all_sum, tcd3.cash_sum, tcd3.pacc_sum,
		tcd3.fund_sum, tcd3.fund_nh_sum, tcd3.fund_commeric,
		tcd3.weixin_sum, tcd3.alipay_sum, tcd3.unionpay_sum,
		tcd3.check_sum, tcd3.voucher_sum, tcd3.spec_sum
	FROM clover_odr.cash_set
	where pay_cate='deposit' and hsp_code=thsp_code and trade_type='0'  
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	tcd3.all_sum_upper := clover_md.udf_digits2hanzi(trunc(tcd3.all_sum):: bigint)||'元'||
	  clover_md.udf_digits2hanzi(((trunc(tcd3.all_sum,1) - trunc(tcd3.all_sum))*10 ):: bigint)||'角'||
	  clover_md.udf_digits2hanzi(((trunc(tcd3.all_sum,2) - trunc(tcd3.all_sum,1))*100 ):: bigint)||'分';
	tcd3.sum01 := 0.00;
	tcd3.sum02 := 0.00;
	tcd3.sum03 := 0.00;
	tcd3.sum04 := tcd3.all_sum;
	tcd3.sum05 := 0.00;
	tcd3.sum06 := 0.00;
	tcd3.sum07 := 0.00;
	tcd3.sum08 := 0.00;
	tcd3.sum09 := 0.00;
	tcd3.sum10 := 0.00;
	tcd3.sum11 := 0.00;
	tcd3.sum12 := 0.00;
	tcd3.sum13 := 0.00;
	tcd3.sum14 := 0.00;
	tcd3.sum15 := 0.00;
	tcd3.sum16 := 0.00;
	tcd3.sum17 := 0.00;
	tcd3.sum18 := 0.00; 
	tcd3.sum19 := 0.00;
	tcd3.sum20 := tcd1.all_sum;
	insert into clover_odr.chk_detail values (tcd3.*);  
	--- ---
	tcd3b.seq := nextval('clover_odr.seq_chk_detail');
	tcd3b.seq_chk_sum := tchksum.seq;
	tcd3b.hsp_code := thsp_code;
	tcd3b.opcode := topcode;
	tcd3b.opname := tchksum.opname;
	tcd3b.chk_type := 'deposit';
	tcd3b.bd := tchksum.bd;
	tcd3b.ed := tchksum.ed;
	tcd3b.chk_time := tstime;
	tcd3b.chk_opcode := topcode;
	tcd3b.trade_type := '-1';
	SELECT to_char(to_number(coalesce(max(chk_flow_detail),'00000000'),'99999999')+1,'00000000') into tcd3b.chk_flow_detail
	  FROM clover_odr.chk_detail where hsp_code=thsp_code and opcode=topcode;
	tcd3b.paper_num := 0;
	SELECT coalesce(max(invoice_nmb),'0000000000'), coalesce(min(invoice_nmb),'0000000000'),
	    coalesce(max(flow_nmb),'0000000000'),coalesce(min(flow_nmb),'0000000000'),
		coalesce(sum(all_sum),0.00), coalesce(sum(cash_sum),0.00), coalesce(sum(pacc_sum),0.00), 
		coalesce(sum(fund_sum),0.00), coalesce(sum(fund_nh_sum),0.00), coalesce(sum(fund_commeric),0.00), 
		coalesce(sum(weixin_sum),0.00), coalesce(sum(alipay_sum),0.00), coalesce(sum(unionpay_sum),0.00), 
		coalesce(sum(check_sum),0.00), coalesce(sum(voucher_sum),0.00), coalesce(sum(spec_sum),0.00)
	into tcd3b.einvoice_nmb,tcd3b.binvoice_nmb,
	    tcd3b.eflow,tcd3b.bflow,
		tcd3b.all_sum, tcd3b.cash_sum, tcd3b.pacc_sum,
		tcd3b.fund_sum, tcd3b.fund_nh_sum, tcd3b.fund_commeric,
		tcd3b.weixin_sum, tcd3b.alipay_sum, tcd3b.unionpay_sum,
		tcd3b.check_sum, tcd3b.voucher_sum, tcd3b.spec_sum
	FROM clover_odr.cash_set
	where pay_cate='deposit' and hsp_code=thsp_code  and trade_type='-1' 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	tcd3b.all_sum_upper := '负'||clover_md.udf_digits2hanzi(trunc(abs(tcd3b.all_sum)):: bigint)||'元'||
	  clover_md.udf_digits2hanzi(((trunc(abs(tcd3b.all_sum),1) - trunc(abs(tcd3b.all_sum)))*10 ):: bigint)||'角'||
	  clover_md.udf_digits2hanzi(((trunc(abs(tcd3b.all_sum),2) - trunc(abs(tcd3b.all_sum),1))*100 ):: bigint)||'分';	
	tcd3b.sum01 := 0.00;
	tcd3b.sum02 := 0.00;
	tcd3b.sum03 := 0.00;
	tcd3b.sum04 := tcd3b.all_sum;
	tcd3b.sum05 := 0.00;
	tcd3b.sum06 := 0.00;
	tcd3b.sum07 := 0.00;
	tcd3b.sum08 := 0.00;
	tcd3b.sum09 := 0.00;
	tcd3b.sum10 := 0.00;
	tcd3b.sum11 := 0.00;
	tcd3b.sum12 := 0.00;
	tcd3b.sum13 := 0.00;
	tcd3b.sum14 := 0.00;
	tcd3b.sum15 := 0.00;
	tcd3b.sum16 := 0.00;
	tcd3b.sum17 := 0.00;
	tcd3b.sum18 := 0.00; 
	tcd3b.sum19 := 0.00;
	tcd3b.sum20 := tcd1.all_sum;
	insert into clover_odr.chk_detail values (tcd3b.*);
	
	--计算出院结算-------discharge-------------------------------------------------------------4444444444444444444444444444--------------------------
	tcd4.seq := nextval('clover_odr.seq_chk_detail');
	tcd4.seq_chk_sum := tchksum.seq;
	tcd4.hsp_code := thsp_code;
	tcd4.opcode := topcode;
	tcd4.opname := tchksum.opname;
	tcd4.chk_type := 'discharge';
	tcd4.bd := tchksum.bd;
	tcd4.ed := tchksum.ed;
	tcd4.chk_time := tstime;
	tcd4.chk_opcode := topcode;
	tcd4.trade_type := '0';
	SELECT to_char(to_number(coalesce(max(chk_flow_detail),'00000000'),'99999999')+1,'00000000') into tcd4.chk_flow_detail
	  FROM clover_odr.chk_detail where hsp_code=thsp_code and opcode=topcode;
	SELECT coalesce(count(p.seq),0) into tcd4.paper_num
	  FROM clover_odr.discharge_prn p,clover_odr.discharge d
      where p.seq_discharge=d.seq and p.prn_status<>'-1' and p.hsp_code=thsp_code
           and d.opcode=topcode and d.settle_time>=tchksum.bd and d.settle_time<tchksum.ed ;
	SELECT coalesce(max(invoice_nmb),'0000000000'), coalesce(min(invoice_nmb),'0000000000'),
	    coalesce(max(flow_nmb),'0000000000'),coalesce(min(flow_nmb),'0000000000'),
		coalesce(sum(all_sum),0.00), coalesce(sum(cash_sum),0.00), coalesce(sum(pacc_sum),0.00), 
		coalesce(sum(fund_sum),0.00), coalesce(sum(fund_nh_sum),0.00), coalesce(sum(fund_commeric),0.00), 
		coalesce(sum(weixin_sum),0.00), coalesce(sum(alipay_sum),0.00), coalesce(sum(unionpay_sum),0.00), 
		coalesce(sum(check_sum),0.00), coalesce(sum(voucher_sum),0.00), coalesce(sum(spec_sum),0.00)
	into tcd4.einvoice_nmb,tcd4.binvoice_nmb,
	    tcd4.eflow,tcd4.bflow,
		tcd4.all_sum, tcd4.cash_sum, tcd4.pacc_sum,
		tcd4.fund_sum, tcd4.fund_nh_sum, tcd4.fund_commeric,
		tcd4.weixin_sum, tcd4.alipay_sum, tcd4.unionpay_sum,
		tcd4.check_sum, tcd4.voucher_sum, tcd4.spec_sum
	FROM clover_odr.cash_set
	where pay_cate='discharge' and hsp_code=thsp_code and trade_type='0' 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	SELECT coalesce(sum(sum01),0.00), coalesce(sum(sum02),0.00), coalesce(sum(sum03),0.00), coalesce(sum(sum04),0.00), coalesce(sum(sum05),0.00),
           coalesce(sum(sum06),0.00), coalesce(sum(sum07),0.00), coalesce(sum(sum08),0.00), coalesce(sum(sum09),0.00), coalesce(sum(sum10),0.00),
	       coalesce(sum(sum11),0.00), coalesce(sum(sum12),0.00), coalesce(sum(sum13),0.00), coalesce(sum(sum14),0.00), coalesce(sum(sum15),0.00),
           coalesce(sum(sum16),0.00), coalesce(sum(sum17),0.00), coalesce(sum(sum18),0.00), coalesce(sum(sum19),0.00), coalesce(sum(sum20),0.00)
	INTO tcd4.sum01, tcd4.sum02, tcd4.sum03, tcd4.sum04, tcd4.sum05, 
	     tcd4.sum06, tcd4.sum07, tcd4.sum08, tcd4.sum09, tcd4.sum10, 
		 tcd4.sum11, tcd4.sum12, tcd4.sum13, tcd4.sum14, tcd4.sum15, 
		 tcd4.sum16, tcd4.sum17, tcd4.sum18, tcd4.sum19, tcd4.sum20
	FROM clover_odr.discharge_fee	
    where hsp_code=thsp_code and opcode=topcode and trade_type='0' 
        and settle_time>=tchksum.bd and settle_time<tchksum.ed; 
	tcd4.all_sum_upper := clover_md.udf_digits2hanzi(trunc(tcd4.all_sum):: bigint)||'元'||
	  clover_md.udf_digits2hanzi(((trunc(tcd4.all_sum,1) - trunc(tcd4.all_sum))*10 ):: bigint)||'角'||
	  clover_md.udf_digits2hanzi(((trunc(tcd4.all_sum,2) - trunc(tcd4.all_sum,1))*100 ):: bigint)||'分';
	insert into clover_odr.chk_detail values (tcd4.*);
	--- ---
	tcd4b.seq := nextval('clover_odr.seq_chk_detail');
	tcd4b.seq_chk_sum := tchksum.seq;
	tcd4b.hsp_code := thsp_code;
	tcd4b.opcode := topcode;
	tcd4b.opname := tchksum.opname;
	tcd4b.chk_type := 'discharge';
	tcd4b.bd := tchksum.bd;
	tcd4b.ed := tchksum.ed;
	tcd4b.chk_time := tstime;
	tcd4b.chk_opcode := topcode;
	tcd4b.trade_type := '-1';
	SELECT to_char(to_number(coalesce(max(chk_flow_detail),'00000000'),'99999999')+1,'00000000') into tcd4b.chk_flow_detail
	  FROM clover_odr.chk_detail where hsp_code=thsp_code and opcode=topcode;
	SELECT coalesce(count(p.seq),0) into tcd4b.paper_num
	  FROM clover_odr.discharge_prn p,clover_odr.discharge d
      where p.seq_discharge=d.seq and p.prn_status='-1' and p.hsp_code=thsp_code
           and d.opcode=topcode and d.settle_time>=tchksum.bd and d.settle_time<tchksum.ed ;
	SELECT coalesce(max(invoice_nmb),'0000000000'), coalesce(min(invoice_nmb),'0000000000'),
	    coalesce(max(flow_nmb),'0000000000'),coalesce(min(flow_nmb),'0000000000'),
		coalesce(sum(all_sum),0.00), coalesce(sum(cash_sum),0.00), coalesce(sum(pacc_sum),0.00), 
		coalesce(sum(fund_sum),0.00), coalesce(sum(fund_nh_sum),0.00), coalesce(sum(fund_commeric),0.00), 
		coalesce(sum(weixin_sum),0.00), coalesce(sum(alipay_sum),0.00), coalesce(sum(unionpay_sum),0.00), 
		coalesce(sum(check_sum),0.00), coalesce(sum(voucher_sum),0.00), coalesce(sum(spec_sum),0.00)
	into tcd4b.einvoice_nmb,tcd4b.binvoice_nmb,
	    tcd4b.eflow,tcd4b.bflow,
		tcd4b.all_sum, tcd4b.cash_sum, tcd4b.pacc_sum,
		tcd4b.fund_sum, tcd4b.fund_nh_sum, tcd4b.fund_commeric,
		tcd4b.weixin_sum, tcd4b.alipay_sum, tcd4b.unionpay_sum,
		tcd4b.check_sum, tcd4b.voucher_sum, tcd4b.spec_sum
	FROM clover_odr.cash_set
	where pay_cate='discharge' and hsp_code=thsp_code and trade_type='-1' 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	SELECT coalesce(sum(sum01),0.00), coalesce(sum(sum02),0.00), coalesce(sum(sum03),0.00), coalesce(sum(sum04),0.00), coalesce(sum(sum05),0.00),
           coalesce(sum(sum06),0.00), coalesce(sum(sum07),0.00), coalesce(sum(sum08),0.00), coalesce(sum(sum09),0.00), coalesce(sum(sum10),0.00),
	       coalesce(sum(sum11),0.00), coalesce(sum(sum12),0.00), coalesce(sum(sum13),0.00), coalesce(sum(sum14),0.00), coalesce(sum(sum15),0.00),
           coalesce(sum(sum16),0.00), coalesce(sum(sum17),0.00), coalesce(sum(sum18),0.00), coalesce(sum(sum19),0.00), coalesce(sum(sum20),0.00)
	INTO tcd4b.sum01, tcd4b.sum02, tcd4b.sum03, tcd4b.sum04, tcd4b.sum05, 
	     tcd4b.sum06, tcd4b.sum07, tcd4b.sum08, tcd4b.sum09, tcd4b.sum10, 
		 tcd4b.sum11, tcd4b.sum12, tcd4b.sum13, tcd4b.sum14, tcd4b.sum15, 
		 tcd4b.sum16, tcd4b.sum17, tcd4b.sum18, tcd4b.sum19, tcd4b.sum20
	FROM clover_odr.discharge_fee	
    where hsp_code=thsp_code and opcode=topcode and trade_type='-1' 
        and settle_time>=tchksum.bd and settle_time<tchksum.ed; 
	tcd4b.all_sum_upper := '负'||clover_md.udf_digits2hanzi(trunc(abs(tcd4b.all_sum)):: bigint)||'元'||
	  clover_md.udf_digits2hanzi(((trunc(abs(tcd4b.all_sum),1) - trunc(abs(tcd4b.all_sum)))*10 ):: bigint)||'角'||
	  clover_md.udf_digits2hanzi(((trunc(abs(tcd4b.all_sum),2) - trunc(abs(tcd4b.all_sum),1))*100 ):: bigint)||'分';	
	insert into clover_odr.chk_detail values (tcd4b.*);
	
	-- 计算总收费收入,写入汇总表-----------------------------------------------------------------555555555555555555555555555------------------------- 
	tchksum.all_sum := tcd1.all_sum + tcd2.all_sum + tcd3.all_sum + tcd4.all_sum
	    +tcd1b.all_sum + tcd2b.all_sum + tcd3b.all_sum + tcd4b.all_sum;
	tchksum.cash_sum := tcd1.cash_sum + tcd2.cash_sum + tcd3.cash_sum+ tcd4.cash_sum
	    +tcd1b.cash_sum + tcd2b.cash_sum + tcd3b.cash_sum+ tcd4b.cash_sum;
	tchksum.pacc_sum := tcd1.pacc_sum + tcd2.pacc_sum+ tcd3.pacc_sum+ tcd4.pacc_sum
	    +tcd1b.pacc_sum + tcd2b.pacc_sum+ tcd3b.pacc_sum+ tcd4b.pacc_sum;
	tchksum.fund_sum := tcd1.fund_sum + tcd2.fund_sum + tcd3.fund_sum+ tcd4.fund_sum
	    +tcd1b.fund_sum + tcd2b.fund_sum + tcd3b.fund_sum+ tcd4b.fund_sum;
	tchksum.fund_nh_sum := tcd1.fund_nh_sum + tcd2.fund_nh_sum + tcd3.fund_nh_sum + tcd4.fund_nh_sum
	    +tcd1b.fund_nh_sum + tcd2b.fund_nh_sum + tcd3b.fund_nh_sum + tcd4b.fund_nh_sum;
	tchksum.fund_commeric := tcd1.fund_commeric + tcd2.fund_commeric + tcd3.fund_commeric + tcd4.fund_commeric
	    +tcd1b.fund_commeric + tcd2b.fund_commeric + tcd3b.fund_commeric + tcd4b.fund_commeric;
	tchksum.weixin_sum := tcd1.weixin_sum + tcd2.weixin_sum + tcd3.weixin_sum + tcd4.weixin_sum
	    +tcd1b.weixin_sum + tcd2b.weixin_sum + tcd3b.weixin_sum + tcd4b.weixin_sum;
	tchksum.alipay_sum := tcd1.alipay_sum + tcd2.alipay_sum + tcd3.alipay_sum + tcd4.alipay_sum
	    +tcd1b.alipay_sum + tcd2b.alipay_sum + tcd3b.alipay_sum + tcd4b.alipay_sum;
	tchksum.unionpay_sum := tcd1.unionpay_sum + tcd2.unionpay_sum + tcd3.unionpay_sum + tcd4.unionpay_sum
	    +tcd1b.unionpay_sum + tcd2b.unionpay_sum + tcd3b.unionpay_sum + tcd4b.unionpay_sum;
	tchksum.check_sum := tcd1.check_sum + tcd2.check_sum + tcd3.check_sum + tcd4.check_sum
	    +tcd1b.check_sum + tcd2b.check_sum + tcd3b.check_sum + tcd4b.check_sum;
	tchksum.voucher_sum := tcd1.voucher_sum + tcd2.voucher_sum + tcd3.voucher_sum + tcd4.voucher_sum
	    +tcd1b.voucher_sum + tcd2b.voucher_sum + tcd3b.voucher_sum + tcd4b.voucher_sum;
	tchksum.spec_sum := tcd1.spec_sum + tcd2.spec_sum + tcd3.spec_sum + tcd4.spec_sum
	    +tcd1b.spec_sum + tcd2b.spec_sum + tcd3b.spec_sum + tcd4b.spec_sum;
    tchksum.sum01 := tcd1.sum01 + tcd2.sum01 + tcd3.sum01 + tcd4.sum01
	    +tcd1b.sum01 + tcd2b.sum01 + tcd3b.sum01 + tcd4b.sum01;
	tchksum.sum02 := tcd1.sum02 + tcd2.sum02 + tcd3.sum02 + tcd4.sum02
	    +tcd1b.sum02 + tcd2b.sum02 + tcd3b.sum02 + tcd4b.sum02;
	tchksum.sum03 := tcd1.sum03 + tcd2.sum03 + tcd3.sum03 + tcd4.sum03
	    +tcd1b.sum03 + tcd2b.sum03 + tcd3b.sum03 + tcd4b.sum03;
	tchksum.sum04 := tcd1.sum04 + tcd2.sum04 + tcd3.sum04 + tcd4.sum04
	    +tcd1b.sum04 + tcd2b.sum04 + tcd3b.sum04 + tcd4b.sum04;
	tchksum.sum05 := tcd1.sum05 + tcd2.sum05 + tcd3.sum05 + tcd4.sum05
	    +tcd1b.sum05 + tcd2b.sum05 + tcd3b.sum05 + tcd4b.sum05;
	tchksum.sum06 := tcd1.sum06 + tcd2.sum06 + tcd3.sum06 + tcd4.sum06
	    +tcd1b.sum06 + tcd2b.sum06 + tcd3b.sum06 + tcd4b.sum06;
	tchksum.sum07 := tcd1.sum07 + tcd2.sum07 + tcd3.sum07 + tcd4.sum07
	    +tcd1b.sum07 + tcd2b.sum07 + tcd3b.sum07 + tcd4b.sum07;
	tchksum.sum08 := tcd1.sum08 + tcd2.sum08 + tcd3.sum08 + tcd4.sum08
	    +tcd1b.sum08 + tcd2b.sum08 + tcd3b.sum08 + tcd4b.sum08;
	tchksum.sum09 := tcd1.sum09 + tcd2.sum09 + tcd3.sum09 + tcd4.sum09
	    +tcd1b.sum09 + tcd2b.sum09 + tcd3b.sum09 + tcd4b.sum09;	
	tchksum.sum10 := tcd1.sum10 + tcd2.sum10 + tcd3.sum10 + tcd4.sum10
	    +tcd1b.sum10 + tcd2b.sum10 + tcd3b.sum10 + tcd4b.sum10;	
	tchksum.sum11 := tcd1.sum11 + tcd2.sum11 + tcd3.sum11 + tcd4.sum11
	    +tcd1b.sum11 + tcd2b.sum11 + tcd3b.sum11 + tcd4b.sum11;	
	tchksum.sum12 := tcd1.sum12 + tcd2.sum12 + tcd3.sum12 + tcd4.sum12
	    +tcd1b.sum12 + tcd2b.sum12 + tcd3b.sum12 + tcd4b.sum12;	
	tchksum.sum13 := tcd1.sum13 + tcd2.sum13 + tcd3.sum13 + tcd4.sum13
	    +tcd1b.sum13 + tcd2b.sum13 + tcd3b.sum13 + tcd4b.sum13;	
	tchksum.sum14 := tcd1.sum14 + tcd2.sum14 + tcd3.sum14 + tcd4.sum14
	    +tcd1b.sum14 + tcd2b.sum14 + tcd3b.sum14 + tcd4b.sum14;	
	tchksum.sum15 := tcd1.sum15 + tcd2.sum15 + tcd3.sum15 + tcd4.sum15
	    +tcd1b.sum15 + tcd2b.sum15 + tcd3b.sum15 + tcd4b.sum15;	
	tchksum.sum16 := tcd1.sum16 + tcd2.sum16 + tcd3.sum16 + tcd4.sum16
	    +tcd1b.sum16 + tcd2b.sum16 + tcd3b.sum16 + tcd4b.sum16;	
	tchksum.sum17 := tcd1.sum17 + tcd2.sum17 + tcd3.sum17 + tcd4.sum17
	    +tcd1b.sum17 + tcd2b.sum17 + tcd3b.sum17 + tcd4b.sum17;	
	tchksum.sum18 := tcd1.sum18 + tcd2.sum18 + tcd3.sum18 + tcd4.sum18
	    +tcd1b.sum18 + tcd2b.sum18 + tcd3b.sum18 + tcd4b.sum18;	
	tchksum.sum19 := tcd1.sum19 + tcd2.sum19 + tcd3.sum19 + tcd4.sum19
	    +tcd1b.sum19 + tcd2b.sum19 + tcd3b.sum19 + tcd4b.sum19;	
	tchksum.sum20 := tcd1.sum20 + tcd2.sum20 + tcd3.sum20 + tcd4.sum20
	    +tcd1b.sum20 + tcd2b.sum20 + tcd3b.sum20 + tcd4b.sum20;	
		
	insert into clover_odr.chk_sum values (tchksum.*);
	
	---------------------------------
    ---返回json字符串数组-----汇总json|分类json array
	SELECT json_agg(row_to_json(clover_odr.chk_sum.*)) into tout_str_sum FROM clover_odr.chk_sum;
	SELECT json_agg(row_to_json(clover_odr.chk_detail.* )) into tout_str_detail	FROM clover_odr.chk_detail;
    RETURN tout_str_sum||'|'||tout_str_detail;
END;
$cloveropen$;