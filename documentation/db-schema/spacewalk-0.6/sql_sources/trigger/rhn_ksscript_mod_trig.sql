-- created by Oraschemadoc Mon Aug 31 10:54:38 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_KSSCRIPT_MOD_TRIG" 
before insert or update on rhnKickstartSession
for each row
begin
	:new.modified := sysdate;
end rhn_ksscript_mod_trig;
ALTER TRIGGER "MIM1"."RHN_KSSCRIPT_MOD_TRIG" ENABLE
 
/
