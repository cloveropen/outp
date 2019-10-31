CREATE OR REPLACE FUNCTION clover_odr.sch_reg4cash(tpid text,thsp_code text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$

DECLARE
    tseq bigint :=0;
	tpatient_name clover_odr.out_reg.patient_name%type;
	tex_pid clover_odr.out_reg.ex_pid%type;
	tpatient_type clover_odr.out_reg.patient_type%type;
	treg_type clover_odr.out_reg.reg_type%type;
	tmi_pacc_left clover_odr.out_reg.mi_pacc_left%type;
	taddr_prov clover_odr.out_reg.addr_prov%type;
	taddr_city clover_odr.out_reg.addr_city%type;
	taddr_county clover_odr.out_reg.addr_county%type;
	taddr_township clover_odr.out_reg.addr_township%type;
	taddr_house_nmb clover_odr.out_reg.addr_house_nmb%type;
	tpay_should clover_odr.out_reg.pay_cash%type := 0.00;
	tpay_cash clover_odr.out_reg.pay_cash%type := 0.00;
	tpay_nfc clover_odr.out_reg.pay_nfc%type := 0.00;
	tpay_pacc clover_odr.out_reg.pay_pacc%type := 0.00;
	tpay_fund clover_odr.out_reg.pay_fund%type := 0.00;
	taddr text;
	tdiag text;
	tout_str text;
BEGIN
    select seq,patient_name,ex_pid,patient_type,reg_type,mi_pacc_left,
		addr_prov, addr_city, addr_county, addr_township, addr_house_nmb,
		pay_cash,pay_nfc,pay_pacc,pay_fund
	into tseq,tpatient_name,tex_pid,tpatient_type,treg_type,tmi_pacc_left,
		taddr_prov, taddr_city, taddr_county, taddr_township, taddr_house_nmb,
		tpay_cash,tpay_nfc,tpay_pacc,tpay_fund
	from clover_odr.out_reg
	where pid=tpid and hsp_code=thsp_code order by seq  limit 1;
	tpay_should := tpay_cash + tpay_nfc + tpay_pacc + tpay_fund;
	SELECT coalesce(diag1_name||'('||diag1_code||')','') into tdiag 
	FROM clover_cdr.outp_visit where pid=tpid and hsp_code=thsp_code order by seq limit 1;
	
	--patient_type 转文字
	SELECT term_name into tpatient_type FROM clover_md.dict_health_term where class_id='per_cate' and term_id=tpatient_type;
	--reg_type 转文字	
	SELECT item_name into treg_type FROM clover_md.dict_reg_item where item_code=treg_type;
	--addr_prov 转文字
	SELECT name into taddr_prov FROM clover_md.dict_addr_prov where province_id=taddr_prov;
	--addr_city 转文字
	SELECT name into taddr_city	FROM clover_md.dict_addr_city where city_id=taddr_city;
	--addr_county 转文字
	SELECT name into taddr_county FROM clover_md.dict_addr_county where country_id=taddr_county;
	--addr_township 转文字
	SELECT name into taddr_township FROM clover_md.dict_addr_street where town_id=taddr_township;
	taddr := coalesce(taddr_prov,'')||coalesce(taddr_city,'')||coalesce(taddr_county,'')||coalesce(taddr_township,'')||coalesce(taddr_house_nmb,'');
	tout_str := '{"seq":'||tseq||',"hsp_code":"'||thsp_code||'","pid":"'||tpid||'","patient_name":"'||coalesce(tpatient_name,'')||'","patient_type":"'||coalesce(tpatient_type,'')||'","reg_type":"'||coalesce(treg_type,'')
	 ||'","ex_pid":"'||coalesce(tex_pid,'')||'","mi_pacc_left":'||tmi_pacc_left||',"addr":"'||taddr||'","diag":"'||coalesce(tdiag,'')||'","pay_should":'||tpay_should||',"pay_cash":'||tpay_cash||',"pay_nfc":'||tpay_nfc
	 ||',"pay_pacc":'||tpay_pacc||',"pay_fund":'||tpay_fund||'}';
	  
	return tout_str;
        
END;
$cloveropen$;