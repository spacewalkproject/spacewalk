-- created by Oraschemadoc Fri Jun 13 14:06:10 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_PACKAGE_MOD_TRIG" 
before insert or update on rhnPackage
for each row
begin
	if :new.last_modified = :old.last_modified then
		:new.last_modified := sysdate;
	end if;
	:new.modified := sysdate;
end;
ALTER TRIGGER "RHNSAT"."RHN_PACKAGE_MOD_TRIG" ENABLE
 
/
