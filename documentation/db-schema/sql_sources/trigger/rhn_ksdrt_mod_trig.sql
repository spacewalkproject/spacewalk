-- created by Oraschemadoc Fri Mar  2 05:58:07 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_KSDRT_MOD_TRIG" 
before insert or update on rhnKickstartDefaultRegToken
for each row
begin
	:new.modified := sysdate;
end rhn_ksdrt_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_KSDRT_MOD_TRIG" ENABLE
 
/
