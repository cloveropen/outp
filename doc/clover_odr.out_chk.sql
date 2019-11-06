CREATE OR REPLACE FUNCTION clover_odr.out_chk(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 收款交接班计算 入参:thsp_code + "|" + ted + "|" + topcode + "|" + tgc; 截止时间入参格式yyyy-mm-dd hh24:mi:ss
DECLARE
    tin_arrays text ARRAY;	
	thsp_code clover_odr.chk_sum.hsp_code%type;  --医院编码
	topcode clover_odr.chk_sum.chk_opcode%type;  -- 交班操作员
	tedstr text;  --截止时间
	tendtime clover_odr.chk_sum.chk_time%type;
	tstime clover_odr.chk_sum.chk_time%type;
	tseq clover_odr.chk_sum.seq%type;
	
	tchksum clover_odr.chk_sum%rowtype;
	tcd1 clover_odr.chk_detail%rowtype;
	tcd2 clover_odr.chk_detail%rowtype;
	tcd3 clover_odr.chk_detail%rowtype;
	tcd4 clover_odr.chk_detail%rowtype;
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
	-- tcd1.trade_type := '0';
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
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	insert into clover_odr.chk_detail values (tcd1.*);
	  
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
	--tcd2.trade_type := '0';
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
	where pay_cate='cash' and hsp_code=thsp_code 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	insert into clover_odr.chk_detail values (tcd2.*);  
	  
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
	-- tcd3.trade_type := '0';
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
	where pay_cate='deposit' and hsp_code=thsp_code 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	insert into clover_odr.chk_detail values (tcd3.*);  
	 
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
	--tcd4.trade_type := '0';
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
	where pay_cate='discharge' and hsp_code=thsp_code 
	  and pay_time>=tchksum.bd and pay_time<tchksum.ed and opcode=topcode ;
	insert into clover_odr.chk_detail values (tcd4.*);
	  
	-- 计算总收费收入,写入汇总表-----------------------------------------------------------------555555555555555555555555555------------------------- 
	tchksum.all_sum := tcd1.all_sum + tcd2.all_sum + tcd3.all_sum + tcd4.all_sum;
	tchksum.cash_sum := tcd1.cash_sum + tcd2.cash_sum + tcd3.cash_sum+ tcd4.cash_sum;
	tchksum.pacc_sum := tcd1.pacc_sum + tcd2.pacc_sum+ tcd3.pacc_sum+ tcd4.pacc_sum;
	tchksum.fund_sum := tcd1.fund_sum + tcd2.fund_sum + tcd3.fund_sum+ tcd4.fund_sum;
	tchksum.fund_nh_sum := tcd1.fund_nh_sum + tcd2.fund_nh_sum + tcd3.fund_nh_sum + tcd4.fund_nh_sum;
	tchksum.fund_commeric := tcd1.fund_commeric + tcd2.fund_commeric + tcd3.fund_commeric + tcd4.fund_commeric;
	tchksum.weixin_sum := tcd1.weixin_sum + tcd2.weixin_sum + tcd3.weixin_sum + tcd4.weixin_sum;
	tchksum.alipay_sum := tcd1.alipay_sum + tcd2.alipay_sum + tcd3.alipay_sum + tcd4.alipay_sum;
	tchksum.unionpay_sum := tcd1.unionpay_sum + tcd2.unionpay_sum + tcd3.unionpay_sum + tcd4.unionpay_sum;
	tchksum.check_sum := tcd1.check_sum + tcd2.check_sum + tcd3.check_sum + tcd4.check_sum;
	tchksum.voucher_sum := tcd1.voucher_sum + tcd2.voucher_sum + tcd3.voucher_sum + tcd4.voucher_sum;
	tchksum.spec_sum := tcd1.spec_sum + tcd2.spec_sum + tcd3.spec_sum + tcd4.spec_sum;
	insert into clover_odr.chk_sum values (tchksum.*);
	
	---------------------------------
    RETURN tseq||'|';
END;
$cloveropen$;