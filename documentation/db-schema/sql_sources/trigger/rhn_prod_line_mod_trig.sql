-- created by Oraschemadoc Fri Jan 22 13:41:00 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM_H1"."RHN_PROD_LINE_MOD_TRIG" 
before insert or update on rhnProductLine
for each row
begin
	:new.modified := sysdate;
	:new.last_modified := sysdate;
end;
ALTER TRIGGER "MIM_H1"."RHN_PROD_LINE_MOD_TRIG" ENABLE
 
/
