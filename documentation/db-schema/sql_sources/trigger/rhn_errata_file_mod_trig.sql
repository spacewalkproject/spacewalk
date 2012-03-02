-- created by Oraschemadoc Fri Mar  2 05:58:06 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_ERRATA_FILE_MOD_TRIG" 
before insert or update on rhnErrataFile
for each row
begin
	:new.modified := sysdate;
end rhn_errata_file_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_ERRATA_FILE_MOD_TRIG" ENABLE
 
/
