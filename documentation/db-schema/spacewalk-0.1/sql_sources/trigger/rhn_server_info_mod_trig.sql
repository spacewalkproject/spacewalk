-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_SERVER_INFO_MOD_TRIG" 
before insert or update on rhnServerInfo
for each row
begin
	if :new.checkin is NULL
	then
	        :new.checkin := sysdate;
	end if;
end;
ALTER TRIGGER "RHNSAT"."RHN_SERVER_INFO_MOD_TRIG" ENABLE
 
/
