-- created by Oraschemadoc Thu Apr 21 10:04:16 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."PRODUCT_NAME_MOD_TRIG" 
before insert or update on rhnProductName
for each row
begin
    :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."PRODUCT_NAME_MOD_TRIG" ENABLE
 
/
