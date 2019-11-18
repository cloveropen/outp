CREATE OR REPLACE FUNCTION clover_odr.out_reg_sch_shifts(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 查询本班次的挂号明细 入参:thsp_code|topcode|tdatetype时间类型  今天 today 本班次 cycle 上班次 last_cycle 昨天 yesterday 三天前 3daysbf 一周前 weekbf
DECLARE
    tin_arrays text ARRAY;	
	thsp_code clover_odr.chk_sum.hsp_code%type;  --医院编码
	topcode clover_odr.chk_sum.chk_opcode%type;  -- 交班操作员
	tchk_flow text;  --结算班次流水号
	tbegtime clover_odr.chk_sum.chk_time%type;
	tendtime clover_odr.chk_sum.chk_time%type;
	
	tout_str text := '';
	tout_str_cancel text := '';
BEGIN
    -- 如果没有班次号,则从操作员查询出上一班的交班时间作为开始时间,截止时间为当前时间
	select  string_to_array(tin_str,'|') into tin_arrays;
	thsp_code := tin_arrays[1];	  
	topcode := tin_arrays[2];
	if array_length(tin_arrays,1)<3 then --当前班次
	  SELECT ed into tbegtime FROM clover_odr.chk_sum where hsp_code=thsp_code and opcode=topcode order by seq desc limit 1;
	  tendtime := now();
	  raise notice '当前班次thsp_code%,topcode=%,tbegtime=%,tendtime=%',thsp_code,topcode,tbegtime,tendtime;
	else
	  tchk_flow := tin_arrays[3];
	  SELECT bd,ed into tbegtime,tendtime FROM clover_odr.chk_sum
	    where chk_flow=tchk_flow and 
	          hsp_code=thsp_code and 
			  opcode=topcode order by seq desc limit 1;
	  if tbegtime is null then 
	    tbegtime := now();
	  end if;
	  if tendtime is null then 
	    tendtime := now();
	  end if;
	  raise notice 'tchk_flow=%, thsp_code%,topcode=%,tbegtime=%,tendtime=%',tchk_flow,thsp_code,topcode,tbegtime,tendtime;
	end if;
		
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