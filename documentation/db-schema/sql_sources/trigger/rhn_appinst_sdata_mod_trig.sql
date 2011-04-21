-- created by Oraschemadoc Thu Apr 21 10:04:16 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_APPINST_SDATA_MOD_TRIG" 
before insert or update on rhnAppInstallSessionData
for each row
begin
	:new.modified := sysdate;
end rhn_appinst_sdata_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_APPINST_SDATA_MOD_TRIG" ENABLE
 
/
