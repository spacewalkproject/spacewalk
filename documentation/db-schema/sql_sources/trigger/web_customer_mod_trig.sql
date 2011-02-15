-- created by Oraschemadoc Thu Jan 20 13:58:35 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."WEB_CUSTOMER_MOD_TRIG" 
before insert or update on web_customer
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."WEB_CUSTOMER_MOD_TRIG" ENABLE
 
/
