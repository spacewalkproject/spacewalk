-- created by Oraschemadoc Tue Nov  2 08:33:17 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SERVERPFL_MOD_TRIG" 
before insert or update on rhnServerPreserveFileList
for each row
begin
	:new.modified := sysdate;
end rhn_serverpfl_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_SERVERPFL_MOD_TRIG" ENABLE
 
/
