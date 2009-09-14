-- created by Oraschemadoc Mon Aug 31 10:54:40 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."WEB_CUSTOMER_MOD_TRIG" 
before insert or update on web_customer
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "MIM1"."WEB_CUSTOMER_MOD_TRIG" ENABLE
 
/
