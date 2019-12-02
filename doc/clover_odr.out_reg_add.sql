CREATE OR REPLACE FUNCTION clover_odr.out_reg_add(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$

DECLARE
    tor clover_odr.out_reg%rowtype;
    tempi clover_md.empi%rowtype;
	torp clover_odr.out_reg_prn%rowtype;
	tdept text := '';
	tdoctor text := '';
	tin_str1 text := '';
BEGIN
    select  tin_str::jsonb - 'tgc,topcode' into tin_str1;
    select * from json_populate_record(null::clover_odr.out_reg,tin_str1::json) into tor;
    select nextval('clover_odr.seq_out_reg') into tor.seq;
	tor.reg_time := now();
	tor.mch_ip := tip;
	tor.reg_cancel := '0';
	tor.review_flag := '0';
	tor.reg_source := '门诊挂号窗口';
	-- 获取挂号员个人流水号
	SELECT to_char(to_number(coalesce(invoice_nmb1,'00000000'),'99999999')+1,'00000000') into tor.flow_nmb
	  FROM clover_md.kd99  where opcode=tor.reg_opcode;
	-- 获取打印挂号单发票流水号(invoice_nmb1)
	select clover_odr.sch_invoice_nmb(tor.reg_opcode) into tin_str1;
	select split_part(tin_str1,'|', 1) into tor.invoice_nmb;
    -- 如果传入了患者主索引号,则本次门诊号=患者主索引号+上次就诊次数+1,否则视为新患者,生成主索引号写入epmi
    if length(trim(coalesce(tor.ex_pid,'')))>6 then
       SELECT coalesce(num_out,0)+1 into tempi.num_out FROM clover_md.empi where patient_id=tor.ex_pid;
       tor.pid := tor.ex_pid||trim(to_char(tempi.num_out,'000'));
       UPDATE clover_md.empi
	SET patient_name=coalesce(tor.patient_name,patient_name),
	   gender=coalesce(tor.gender,gender), 
	   idcard=coalesce(tor.idcard,idcard), 
	   micard=coalesce(tor.micard,micard),
	   mi_type=coalesce(tor.mi_type,mi_type), 
	   employer_org_name=coalesce(tor.mi_company,tor.company,employer_org_name), 
	   addr_prov=coalesce(tor.addr_prov,addr_prov), 
	   addr_city=coalesce(tor.addr_city,addr_city), 
	   addr_county=coalesce(tor.addr_county,addr_county), 
	   addr_township=coalesce(tor.addr_township,addr_township), 
	   addr_street=coalesce(tor.addr_street,addr_street), 
	   addr_house_nmb=coalesce(tor.mi_type,addr_house_nmb),
	   sources='门诊窗口挂号更新',
	   up_time=now(),
	   up_person=tor.reg_opcode, 
	   num_out=tempi.num_out
	WHERE patient_id = tor.ex_pid;
    -----------------------------新患者,需要建立主索引档案------------------------------------------------
    else
       select trim(to_char(nextval('clover_odr.pid'),'000000000')) into tor.ex_pid;
       tor.pid := tor.ex_pid||'001';
       --  建立新的患者主索引记录
       tempi.patient_id := tor.ex_pid;
       tempi.patient_name := tor.patient_name;
       tempi.match_type := '符合';
       tempi.gender := tor.gender;
       tempi.idcard := tor.idcard;
       tempi.micard := tor.micard;
       tempi.mi_type := tor.mi_type;
       tempi.employer_org_name := tor.mi_company;
	   tempi.addr_prov := tor.addr_prov;
       tempi.addr_city := tor.addr_city;
       tempi.addr_county := tor.addr_county;
       tempi.addr_township := tor.addr_township;
       tempi.addr_street := tor.addr_street;
       tempi.addr_house_nmb := tor.addr_house_nmb;
       tempi.sources := '门诊窗口挂号新增';
       tempi.status := '有效';
       tempi.create_org := tor.hsp_code;
       tempi.create_time := now();
       tempi.create_person := tor.reg_opcode; 
       tempi.num_out :=1;
       tempi.num_in := 0;

       insert into clover_md.empi values (tempi.*);

    end if;
	----------------------------------------end empi-----------------------------------------
	tor.visit_flag := '0'; --'0' 未支付 1-已支付 2-已接诊
    insert into clover_odr.out_reg values (tor.*);
	------------------------------写入打印挂号单记录表，状态是未交费-------------------------
	begin
	  SELECT dept_name into tdept
	    FROM clover_md.dict_department where dept_code = tor.dept_code;
	  if (length(trim(coalesce(tor.doctor_code,''))))>1 then
	    SELECT person_name into tdoctor
	      FROM clover_md.dict_person where person_id=tor.doctor_code;
	  else
	    tdoctor := '';
	  end if;
	end;
    select nextval('clover_odr.seq_out_reg_prn') into torp.seq;
	torp.hsp_code := tor.hsp_code;
	torp.pid := tor.pid;
	torp.ex_pid := tor.ex_pid;
	torp.patient_name := tor.patient_name;
	torp.reg_type := tor.reg_type;
	torp.wait_period := '全天';
	torp.dept := tdept;
	torp.doctor := tdoctor;
	torp.location := '';
	torp.pay_type := tor.pay_type;
	torp.reg_price := tor.reg_price;
	torp.check_price := tor.check_price;
	torp.pay_cash := tor.pay_cash;
	torp.pay_fund := tor.pay_fund;
	torp.pay_pacc := tor.pay_pacc;
	torp.pay_nfc := tor.pay_nfc;
	torp.reg_opcode := tor.reg_opcode;
	torp.reg_time := tor.reg_time;
	torp.flow_nmb := tor.flow_nmb;
	torp.invoice_nmb := tor.invoice_nmb;
	torp.prn_status := '0';
	torp.patient_type := tor.patient_type;
	torp.mi01 := '';
	torp.mi02 := '';
	torp.mi03 := '';
	torp.mi04 := '';
	torp.mi05 := '';
	torp.mi06 := '';
	torp.mi07 := '';
	torp.mi08 := '';
	torp.mi09 := '';
	torp.mi10 := '';
	torp.mi11 := '';
	insert into clover_odr.out_reg_prn values (torp.*);
	------------------------------------------------------------------------------------------
	-- 更新操作员表的流水号
	UPDATE clover_md.kd99 SET  invoice_nmb1=tor.flow_nmb where opcode = tor.reg_opcode;
	-- 更新票据表的票据号
	UPDATE clover_odr.invoice_op
	SET optime=now(), invoice_nmb1=tor.invoice_nmb
	WHERE opcode=tor.reg_opcode;
	---------------------------------
    RETURN tor.pid;
END;
$cloveropen$;