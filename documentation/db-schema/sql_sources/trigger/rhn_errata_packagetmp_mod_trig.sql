-- created by Oraschemadoc Thu Jan 20 13:57:35 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_ERRATA_PACKAGETMP_MOD_TRIG" 
before insert or update on rhnErrataPackageTmp
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_ERRATA_PACKAGETMP_MOD_TRIG" ENABLE
 
/
