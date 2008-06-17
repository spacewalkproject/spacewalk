-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_SE_MOD_TRIG" 
before insert or update on rhnServerEvent
for each row
begin
	:new.modified := sysdate;
end;
ALTER TRIGGER "RHNSAT"."RHN_SE_MOD_TRIG" ENABLE
 
/
