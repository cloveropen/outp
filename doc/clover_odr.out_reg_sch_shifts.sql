CREATE OR REPLACE FUNCTION clover_odr.out_reg_sch_shifts(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 查询本班次的挂号明细 入参:thsp_code|topcode|tdatetype时间段分类  今天 today 本班次 cycle 上班次 last_cycle 昨天 yesterday 三天前 3daysbf 一周前 weekbf 一个月内monthbf
DECLARE
    tin_arrays text ARRAY;	
	thsp_code clover_odr.chk_sum.hsp_code%type;  --医院编码
	topcode clover_odr.chk_sum.chk_opcode%type;  -- 交班操作员
	tdate_type text;  --时间段分类
	tbegtime clover_odr.chk_sum.chk_time%type;
	tendtime clover_odr.chk_sum.chk_time%type;
	
	tout_str text := '';
	tout_str_cancel text := '';
BEGIN
    -- 如果没有班次号,则从操作员查询出上一班的交班时间作为开始时间,截止时间为当前时间
	select  string_to_array(tin_str,'|') into tin_arrays;
	thsp_code := tin_arrays[1];	  
	topcode := tin_arrays[2];
	tdate_type := tin_arrays[3];
	CASE tdate_type
    WHEN 'today' THEN
		raise notice 'tday';
		select date_trunc('day',now()),now() into tbegtime,tendtime;
    WHEN 'cycle' THEN
		raise notice 'cycle';
		SELECT ed into tbegtime FROM clover_odr.chk_sum where hsp_code=thsp_code and opcode=topcode order by seq desc limit 1;
		tendtime := now();
    WHEN 'last_cycle' THEN
		raise notice 'last_cycle';
		SELECT bd,ed into tbegtime,tendtime FROM clover_odr.chk_sum
	    where hsp_code=thsp_code and 
			  opcode=topcode order by seq desc limit 1;
		if tbegtime is null then 
			tbegtime := now();
		end if;
		if tendtime is null then 
			tendtime := now();
		end if;
    WHEN 'yesterday' THEN
		raise notice 'yesterday';
		select date_trunc('day',now()) - interval '1 days',now() into tbegtime,tendtime;
    WHEN '3daysbf' THEN
		raise notice '3daysbf';
		select date_trunc('day',now()) - interval '3 days',now() into tbegtime,tendtime;
    WHEN 'weekbf' THEN
		raise notice 'weekbf';    
		select date_trunc('day',now()) - interval '1 weeks',now() into tbegtime,tendtime;
	WHEN 'monthbf' THEN
		raise notice 'monthbf';    
		select date_trunc('day',now()) - interval '1 months',now() into tbegtime,tendtime;
    ELSE
	  tout_str := '[{}]';
	  tout_str_cancel := '[{}]';
      RETURN tout_str||'|'||tout_str_cancel;
    END CASE;
	
		
    execute 'DROP TABLE IF EXISTS t_out_reg,t_out_reg_cancel';
    execute 'CREATE TEMP TABLE t_out_reg as select * from clover_odr.out_reg with no data';
    execute 'CREATE TEMP TABLE t_out_reg_cancel as select * from clover_odr.out_reg with no data';
	
	insert into t_out_reg select * from clover_odr.out_reg_view
      where hsp_code=thsp_code and reg_opcode=topcode 
	  and reg_time>=tbegtime and reg_time<tendtime and reg_cancel='0' order by reg_time;
	insert into t_out_reg_cancel select * from clover_odr.out_reg_view
      where hsp_code=thsp_code and reg_opcode=topcode 
	  and reg_time>=tbegtime and reg_time<tendtime and reg_cancel='-1' order by reg_time;  

	---------------------------------
	---返回json字符串数组-----汇总json|分类json array
	SELECT coalesce(json_agg(row_to_json(t_out_reg.*)),'[{}]') into tout_str FROM t_out_reg;
	SELECT coalesce(json_agg(row_to_json(t_out_reg_cancel.* )),'[{}]') into tout_str_cancel FROM t_out_reg_cancel;
    RETURN tout_str||'|'||tout_str_cancel;
END;
$cloveropen$;