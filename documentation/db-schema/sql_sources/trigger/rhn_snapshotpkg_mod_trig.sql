-- created by Oraschemadoc Thu Apr 21 10:04:19 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SNAPSHOTPKG_MOD_TRIG" 
before insert or update on rhnSnapshotPackage
for each row
begin
	update rhnSnapshot set modified = sysdate where id = :new.snapshot_id;
end;
ALTER TRIGGER "SPACEWALK"."RHN_SNAPSHOTPKG_MOD_TRIG" ENABLE
 
/
