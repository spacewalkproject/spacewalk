-- created by Oraschemadoc Thu Apr 21 10:04:17 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_KSTREEFILE_MOD_TRIG" 
before insert or update on rhnKSTreeFile
for each row
begin
	:new.modified := sysdate;
	-- allow us to manually set last_modified if we wish
	if :new.last_modified = :old.last_modified
	then
  	    :new.last_modified := sysdate;
        end if;
end rhn_kstreefile_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_KSTREEFILE_MOD_TRIG" ENABLE
 
/
