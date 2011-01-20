-- created by Oraschemadoc Thu Jan 20 13:57:26 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_EFILEC_MOD_TRIG" 
before insert or update on rhnErrataFileChannel
for each row
begin
	:new.modified := sysdate;
end rhn_efilec_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_EFILEC_MOD_TRIG" ENABLE
 
/
