CREATE OR REPLACE FUNCTION clover_odr.calc_fee_itemsum(thsp_code text,topcode text,tbd timestamp,ted timestamp,titem_class text,ttrade_type text)
    RETURNS numeric(12,4)
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 计算门诊收款分项收入
DECLARE    
	tsum numeric(12,4);	
BEGIN
  if ttrade_type='0' then
    --正常收费
	SELECT coalesce(sum(item_sum),0.00) into tsum
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and cash_opcode=topcode 
	    and cashtime>=tbd and cashtime<ted and quantity>=0
		and presc_status<>'9' and item_class=titem_class;
  else
    -- 是退费 反交易
	SELECT coalesce(sum(item_sum),0.00) into tsum
	  FROM clover_odr.fee_detail
	where hsp_code=thsp_code and cash_opcode=topcode 
	    and cashtime>=tbd and cashtime<ted and quantity<0
		and presc_status<>'9' and item_class=titem_class;
  end if;
  RETURN tsum;
END;
$cloveropen$;