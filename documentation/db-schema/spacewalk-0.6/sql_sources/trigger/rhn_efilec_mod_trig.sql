-- created by Oraschemadoc Mon Aug 31 10:54:37 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_EFILEC_MOD_TRIG" 
before insert or update on rhnErrataFileChannel
for each row
begin
	:new.modified := sysdate;
end rhn_efilec_mod_trig;
ALTER TRIGGER "MIM1"."RHN_EFILEC_MOD_TRIG" ENABLE
 
/
