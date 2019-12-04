CREATE OR REPLACE FUNCTION clover_odr.sch_invoice_nmb(topcode text,tnums integer)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$

DECLARE
    top clover_odr.invoice_op%rowtype;
    tseq bigint :=0;
BEGIN
    --  查询返回当前操作员的发票号,如果没有记录增加一条初始化数据
	if tnums<=0 then
	  return '';
	end if;
	select coalesce(max(seq),0) into tseq from clover_odr.invoice_op where opcode = topcode;
	if tseq>0 then
	  SELECT invoice_nmb1,invoice_nmb2,invoice_nmb3,
			 invoice_nmb4,invoice_nmb5,invoice_nmb6
	  into top.invoice_nmb1,top.invoice_nmb2,top.invoice_nmb3,
		   top.invoice_nmb4,top.invoice_nmb5,top.invoice_nmb6
	    FROM clover_odr.invoice_op where seq = tseq;
	  CASE
      WHEN tnums=1 THEN 
	    top.invoice_nmb1 := trim(to_char(to_number(coalesce(top.invoice_nmb1,'00000000'),'99999999')+1,'00000000'));
      WHEN tnums=2 THEN
	    top.invoice_nmb2 := trim(to_char(to_number(coalesce(top.invoice_nmb2,'00000000'),'99999999')+1,'00000000'));
      WHEN tnums=3 THEN
	    top.invoice_nmb3 := trim(to_char(to_number(coalesce(top.invoice_nmb3,'00000000'),'99999999')+1,'00000000'));
	  WHEN tnums=4 THEN
	    top.invoice_nmb4 := trim(to_char(to_number(coalesce(top.invoice_nmb4,'00000000'),'99999999')+1,'00000000'));
	  WHEN tnums=5 THEN
	    top.invoice_nmb5 := trim(to_char(to_number(coalesce(top.invoice_nmb5,'00000000'),'99999999')+1,'00000000'));
	  WHEN tnums=6 THEN
	    top.invoice_nmb6 := trim(to_char(to_number(coalesce(top.invoice_nmb6,'00000000'),'99999999')+1,'00000000'));
	  END CASE;
	  UPDATE clover_odr.invoice_op
	    SET optime=now(), 
	    invoice_nmb1=top.invoice_nmb1, 
	    invoice_nmb2=top.invoice_nmb2, 
	    invoice_nmb3=top.invoice_nmb3, 
	    invoice_nmb4=top.invoice_nmb4, 
	    invoice_nmb5=top.invoice_nmb5, 
	    invoice_nmb6=top.invoice_nmb6
	    WHERE seq = tseq;
	else
	    SELECT hsp_code, opname into top.hsp_code,top.opname FROM clover_md.kd99 where opcode = topcode;
		top.opcode := topcode;
		select nextval('clover_odr.seq_invoice_op') into top.seq;
		top.invoice_nmb1 := '00000001';
		top.invoice_nmb2 := '00000001';
		top.invoice_nmb3 := '00000001';
		top.invoice_nmb4 := '00000001';
		top.invoice_nmb5 := '00000001';
		top.invoice_nmb6 := '00000001';
		INSERT INTO clover_odr.invoice_op values (top.*);
	end if;
    RETURN top.invoice_nmb1||'|'||top.invoice_nmb2||'|'||top.invoice_nmb3||'|'||top.invoice_nmb4||'|'||top.invoice_nmb5||'|'||top.invoice_nmb6;
END;
$cloveropen$;