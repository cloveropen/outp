CREATE OR REPLACE FUNCTION clover_odr.sch_invoice_nmb(topcode text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$

DECLARE
    top clover_odr.invoice_op%rowtype;
    tseq bigint :=0;
	torp clover_odr.out_reg_prn%rowtype;
	tdept text := '';
	tdoctor text := '';
	tin_str1 text := '';
BEGIN
    --  查询返回当前操作员的发票号,如果没有记录增加一条初始化数据
	select coalesce(max(seq),0) tseq from clover_odr.invoice_op where opcode = topcode;
	if tseq>0 then
	  SELECT to_char(to_number(coalesce(invoice_nmb1,'00000000'),'99999999')+1,'00000000'),
        to_char(to_number(coalesce(invoice_nmb2,'00000000'),'99999999')+1,'00000000'),
		to_char(to_number(coalesce(invoice_nmb3,'00000000'),'99999999')+1,'00000000'),
		to_char(to_number(coalesce(invoice_nmb4,'00000000'),'99999999')+1,'00000000'),
		to_char(to_number(coalesce(invoice_nmb5,'00000000'),'99999999')+1,'00000000'),
		to_char(to_number(coalesce(invoice_nmb6,'00000000'),'99999999')+1,'00000000')
	  into top.invoice_nmb1,
		   top.invoice_nmb2,
		   top.invoice_nmb3,
		   top.invoice_nmb4,
		   top.invoice_nmb5,
		   top.invoice_nmb6
	    FROM clover_odr.invoice_op where seq = tseq;
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