-- created by Oraschemadoc Fri Jun 13 14:06:10 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_KSTREEFILE_MOD_TRIG" 
before insert or update on rhnKSTreeFile
for each row
begin
	:new.modified := sysdate;
	if :new.last_modified = :old.last_modified
	then
  	    :new.last_modified := sysdate;
        end if;
end rhn_kstreefile_mod_trig;
ALTER TRIGGER "RHNSAT"."RHN_KSTREEFILE_MOD_TRIG" ENABLE
 
/
