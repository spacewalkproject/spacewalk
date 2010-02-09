-- created by Oraschemadoc Fri Jan 22 13:40:57 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_EFILECTMP_MOD_TRIG"
before insert or update on rhnErrataFileChannelTmp
for each row
begin
	:new.modified := sysdate;
end rhn_efilectmp_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_EFILECTMP_MOD_TRIG" ENABLE
 
/
