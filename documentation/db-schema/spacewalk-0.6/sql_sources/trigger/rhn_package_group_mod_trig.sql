-- created by Oraschemadoc Mon Aug 31 10:54:38 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_PACKAGE_GROUP_MOD_TRIG" 
before insert or update on rhnPackageGroup
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "MIM1"."RHN_PACKAGE_GROUP_MOD_TRIG" ENABLE
 
/
