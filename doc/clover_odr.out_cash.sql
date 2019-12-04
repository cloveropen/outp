CREATE OR REPLACE FUNCTION clover_odr.out_cash(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 门诊收款 入参:tpid + "|" + thsp_code + "|" + topcode + "|" + tgc;
DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.fee_detail.pid%type;
	thsp_code clover_odr.fee_detail.hsp_code%type;
	topcode clover_odr.fee_detail.cash_opcode%type;
	tstime clover_odr.fee_detail.cashtime%type;
	treceipt_nmb clover_odr.fee_detail.receipt_nmb%type;
	tflow_nmb clover_odr.fee_detail.flow_nmb%type;
	tinvoice_nmb clover_odr.fee_detail.invoice_nmb%type;
	tall_sum clover_odr.fee_detail.item_sum%type; 
	
	tfs clover_odr.fee_settle%rowtype;
	tprn clover_odr.out_cash_prn%rowtype;
	tin_str1 text := '';
	
BEGIN
    select  string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	thsp_code := tin_arrays[2];
	topcode := tin_arrays[3];
	raise notice 'tpid=%,thsp_code=%,topcode=%',tpid,thsp_code,topcode;
	tstime := now();
	-- 生成本次结算号
	select to_char(nextval('clover_odr.seq_receipt_nmb'),'0000000000') into treceipt_nmb;
	-- 获取收款员个人流水号
	SELECT to_char(to_number(coalesce(invoice_nmb2,'00000000'),'99999999')+1,'00000000') into tflow_nmb
	  FROM clover_md.kd99  where opcode=topcode;
	-- 获取打印门诊发票流水号(invoice_nmb2)
	select clover_odr.sch_invoice_nmb(topcode,2) into tin_str1;
	select split_part(tin_str1,'|', 2) into tinvoice_nmb;
	-- 计算本次应交费用，当前时间前7天
	select coalesce(sum(item_sum),0.00) into tall_sum
	  from clover_odr.fee_detail
	WHERE hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9';
	
	-- 写入单次结算表
	tfs.seq := nextval('clover_odr.seq_fee_settle');	
	tfs.hsp_code := thsp_code;
	tfs.pid_type := 'O';
	tfs.pid := tpid;
	SELECT ex_pid, patient_name, patient_type, reg_type,mi_type, micard
	  into tfs.ex_pid,tfs.patient_name,tfs.patient_type,tprn.reg_type,tprn.mi_type,tprn.mi02
	FROM clover_odr.out_reg where pid = tpid order by seq limit 1 ;
	tfs.receipt_nmb := treceipt_nmb;
	tfs.cash_cancel := '0';
	tfs.settle_time := tstime;
	tfs.settle_str := '';
	tfs.all_sum := tall_sum;
	tfs.cash_sum := 0.00;
	tfs.pacc_sum := 0.00;
	tfs.fund_sum := 0.00;
	tfs.fund_nh_sum := 0.00;
	tfs.fund_commeric := 0.00;
	tfs.weixin_sum := 0.00;
	tfs.alipay_sum := 0.00;
	tfs.unionpay_sum := 0.00;
	tfs.check_sum := 0.00;
	tfs.voucher_sum := 0.00;
	tfs.spec_sum := 0.00;
	tfs.mch_ip := tip;
	tfs.opcode := topcode;
	tfs.handover := '0';
	insert into clover_odr.fee_settle values (tfs.*);
	-- 写入门诊收据打印表
	--mi_feetype=11	收费类别	西药
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum01
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='11';
	--mi_feetype=12	收费类别	中成药
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum02
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='12';
	--mi_feetype=13	收费类别	中草药
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum03
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='13';
	--mi_feetype=21	收费类别	检查费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum04
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='21';
	--mi_feetype=22	收费类别	特殊检查费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum05
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='22';
	--mi_feetype=23	收费类别	输氧费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum06
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='23';
	--mi_feetype=24	收费类别	手术费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum07
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='24';
	--mi_feetype=25	收费类别	化验费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum08
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='25';
	--mi_feetype=26	收费类别	输血费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum09
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='26';
	--mi_feetype=27	收费类别	诊察费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum10
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='27';
	--mi_feetype=28	收费类别	材料费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum11
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='28';
	--mi_feetype=29	收费类别	特殊材料费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum12
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='29';
	--mi_feetype=31	收费类别	治疗费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum13
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='31';
	--mi_feetype=32	收费类别	特殊治疗费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum14
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='32';
	--mi_feetype=33	收费类别	护理费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum15
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='33';
	--mi_feetype=34	收费类别	床位费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum16
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='34';
	--mi_feetype=35	收费类别	取暖费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum17
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='35';
	--mi_feetype=36	收费类别	一次性医用材料
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum18
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='36';
	--mi_feetype=91	收费类别	其他费用
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum19
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='91';
	--mi_feetype=92	收费类别	挂号费
	SELECT coalesce(sum(item_sum),0.00) into tprn.sum20
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9' and item_class='92';
	-- 写入打印发票记录表
	tprn.seq := nextval('clover_odr.seq_out_cash_prn');
	tprn.hsp_code := thsp_code;
	tprn.pid := tpid;
    tprn.ex_pid := tfs.ex_pid;  --主索引号
    tprn.patient_name := tfs.patient_name;  --患者姓名
    
    --tprn.reg_type :=   --挂号类别
    --tprn.patient_type :=  --患者类型
    tprn.pay_sum_upper := clover_md.udf_digits2hanzi(trunc(tall_sum):: bigint)||'元'||
	 clover_md.udf_digits2hanzi(((trunc(tall_sum,1) - trunc(tall_sum))*10 ):: bigint)||'角'||
	 clover_md.udf_digits2hanzi(((trunc(tall_sum,2) - trunc(tall_sum,1))*100 ):: bigint)||'分'; -- 医疗总费用大写|pay_sum_upper |text
    tprn.pay_sum := tall_sum;   -- 医疗总费用
    tprn.pay_cash := tall_sum;   -- 现金支付
    tprn.pay_fund := 0.00;   -- 统筹支付
    tprn.pay_pacc := 0.00;   -- 医保帐户
    tprn.pay_fund_db := 0.00;   -- 低保支付
    tprn.pay_fund_large := 0.00;   -- 大额支付
    tprn.pay_wechat := 0.00;   -- 微信支付
    tprn.pay_alipay := 0.00;   --支付宝支付
    tprn.pay_unionpay := 0.00;   -- 银行卡支付
    tprn.pay_fund_gwy := 0.00;   -- 公务员补助
    tprn.pay_lixiu := 0.00;  -- 离干统筹
    tprn.cash_opcode := topcode;   -- 收款员
    tprn.cash_time := tstime;  --收款时间
    tprn.flow_nmb := tflow_nmb;   --流水号
    tprn.invoice_nmb := tinvoice_nmb;  --票据号
    tprn.prn_status := '1';  --状态(未支付 已交款 已打印)
    tprn.mi_type := '';  --人员类别
    tprn.mi01 :='';  --医保病种 
    tprn.mi02 :='';  --医保个人编号 
    tprn.mi03 :='';  --报销前自费
    tprn.mi04 :='';  --本次起付标准
    tprn.mi05 :='';  --医保报销范围
    tprn.mi06 :='';  --统筹内个人自付
    tprn.mi07 :='';  --本年统筹累计
    tprn.mi08 :='';  --本年特困救助累计
    tprn.mi09 :='';  --本年大额起付累计
    tprn.mi10 :='';  --本次大额报销范围
    tprn.mi11 :='';  --本次大额报销金额
    tprn.mi12 :='';  --本年大额累计
    tprn.mi13 :='';  --个人支付总额
    tprn.mi14 :='';  --报销比例
	tprn.mch_ip := tip;
	tprn.receipt_nmb := treceipt_nmb;
	-- 如果是现金支付，写入支付记录表
	insert into clover_odr.out_cash_prn values (tprn.*);
	-- 更新费用明细表状态
	UPDATE clover_odr.fee_detail
	  SET cashtime=tstime, 
		  cash_opcode=topcode, 
		  presc_status='1', 
		  invoice_nmb=tinvoice_nmb, 
		  flow_nmb=tflow_nmb,
		  receipt_nmb=treceipt_nmb
	WHERE hsp_code=thsp_code and pid=tpid and cal_time>now() - interval '7 days' and presc_status='9';
	
	---------------------------------
    RETURN treceipt_nmb||'|'||trim(to_char(tall_sum,'999999999999.99'));
END;
$cloveropen$;