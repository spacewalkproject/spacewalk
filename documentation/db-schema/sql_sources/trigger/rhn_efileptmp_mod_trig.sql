-- created by Oraschemadoc Thu Jan 20 13:57:28 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_EFILEPTMP_MOD_TRIG" 
before insert or update on rhnErrataFilePackageTmp
for each row
begin
	:new.modified := sysdate;
end rhn_efilep_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_EFILEPTMP_MOD_TRIG" ENABLE
 
/
