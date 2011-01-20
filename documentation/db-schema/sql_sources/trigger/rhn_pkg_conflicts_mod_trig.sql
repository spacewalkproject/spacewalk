-- created by Oraschemadoc Thu Jan 20 13:57:54 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_PKG_CONFLICTS_MOD_TRIG" 
before insert or update on rhnPackageConflicts
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_PKG_CONFLICTS_MOD_TRIG" ENABLE
 
/
