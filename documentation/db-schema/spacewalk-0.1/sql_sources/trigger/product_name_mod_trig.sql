-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."PRODUCT_NAME_MOD_TRIG" 
before insert or update on rhnProductName
for each row
begin
    :new.modified := sysdate;
end;
ALTER TRIGGER "RHNSAT"."PRODUCT_NAME_MOD_TRIG" ENABLE
 
/
