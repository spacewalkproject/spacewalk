-- created by Oraschemadoc Mon Aug 31 10:54:40 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_SNAPSHOTSG_MOD_TRIG" 
before insert or update on rhnSnapshotServerGroup
for each row
begin
	update rhnSnapshot set modified = sysdate where id = :new.snapshot_id;
end;
ALTER TRIGGER "MIM1"."RHN_SNAPSHOTSG_MOD_TRIG" ENABLE
 
/
