-- created by Oraschemadoc Thu Apr 21 10:04:19 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_TEMPLATE_STR_MOD_TRIG" 
before insert or update on rhnTemplateString
for each row
begin
	:new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_TEMPLATE_STR_MOD_TRIG" ENABLE
 
/
