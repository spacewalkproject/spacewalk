-- created by Oraschemadoc Tue Nov  2 08:33:17 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_PKGSRC_MOD_TRIG" 
before insert or update on rhnPackageSource
for each row
begin
        :new.modified := sysdate;
	:new.last_modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_PKGSRC_MOD_TRIG" ENABLE
 
/
