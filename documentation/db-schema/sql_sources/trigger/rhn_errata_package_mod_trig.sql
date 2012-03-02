-- created by Oraschemadoc Fri Mar  2 05:58:06 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_ERRATA_PACKAGE_MOD_TRIG" 
before insert or update or delete on rhnErrataPackage
for each row
begin
	if inserting or updating then
		:new.modified := sysdate;
	end if;
	if deleting then
		update rhnErrata
		set rhnErrata.last_modified = sysdate
		where rhnErrata.id in ( :old.errata_id );
	end if;
end rhn_errata_package_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_ERRATA_PACKAGE_MOD_TRIG" ENABLE
 
/
