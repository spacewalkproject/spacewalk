-- created by Oraschemadoc Tue Jul 19 17:31:31 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."PRODUCT_NAME_MOD_TRIG" 
before insert or update on rhnProductName
for each row
begin
    :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."PRODUCT_NAME_MOD_TRIG" ENABLE
 
/
