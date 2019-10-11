CREATE OR REPLACE FUNCTION clover_odr.out_reg_add(tin_str text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$

DECLARE
    tor clover_odr.out_reg%rowtype;
    tempi clover_md.empi%rowtype;
BEGIN
    select * from json_populate_record(null::clover_odr.out_reg,tin_str::json) into tor;
    select nextval('clover_odr.seq_out_reg') into tor.seq;
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
	   addr_prov=coalesce(tor.mi_type,mi_type), 
	   addr_city=coalesce(tor.mi_type,mi_type), 
	   addr_county=coalesce(tor.mi_type,mi_type), 
	   addr_township=coalesce(tor.mi_type,mi_type), 
	   addr_street=coalesce(tor.mi_type,mi_type), 
	   addr_house_nmb=coalesce(tor.mi_type,mi_type),
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
    insert into clover_odr.out_reg values (tor.*);

    RETURN tor.pid;
END;
$cloveropen$;