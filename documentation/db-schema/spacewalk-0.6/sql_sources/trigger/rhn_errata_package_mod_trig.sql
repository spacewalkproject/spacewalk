-- created by Oraschemadoc Mon Aug 31 10:54:38 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_ERRATA_PACKAGE_MOD_TRIG" 
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
ALTER TRIGGER "MIM1"."RHN_ERRATA_PACKAGE_MOD_TRIG" ENABLE
 
/
