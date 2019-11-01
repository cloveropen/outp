CREATE OR REPLACE FUNCTION clover_odr.sch_reg4cash_list(thsp_code text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
    -- 查询待交款的患者列表
    -- 返回列表 门诊号 姓名 挂号类别 用户类别 待交款合计
DECLARE
    tpid clover_odr.out_reg.pid%type;
    tpatient_name clover_odr.out_reg.patient_name%type;	
    tpatient_type clover_odr.out_reg.patient_type%type;
    treg_type clover_odr.out_reg.reg_type%type;
    tpay_should clover_odr.out_reg.pay_cash%type := 0.00;	
    cursor_reg4cash refcursor;
    tout_str text;
BEGIN
    execute 'DROP TABLE IF EXISTS t_reg4cash';
    execute 'CREATE TEMP TABLE t_reg4cash(pid text, patient_name text, patient_type text, reg_type text,pay_should numeric(12,4))';
	
     OPEN cursor_reg4cash FOR
        SELECT distinct pid,patient_name, patient_type, reg_type
	  FROM clover_odr.fee_detail where hsp_code=thsp_code and presc_status='9' order by patient_name;
	FETCH  cursor_reg4cash into tpid,tpatient_name, tpatient_type, treg_type;
    while found loop
        SELECT coalesce(sum(real_price*quantity*days),0.00) into tpay_should
          FROM clover_odr.fee_detail
        where pid=tpid and patient_name=tpatient_name and patient_type=tpatient_type and reg_type=treg_type;
        insert into t_reg4cash values (tpid,tpatient_name, tpatient_type, treg_type, tpay_should);
        FETCH next from  cursor_reg4cash into tpid,tpatient_name, tpatient_type, treg_type;	  
    end loop;
    close cursor_reg4cash; 
    select array_to_json(array_agg(row_to_json(t)))::text into tout_str
    from (
      select pid, patient_name, patient_type, reg_type,pay_should from t_reg4cash
    ) AS t;

    RETURN tout_str;	      
END;
$cloveropen$;