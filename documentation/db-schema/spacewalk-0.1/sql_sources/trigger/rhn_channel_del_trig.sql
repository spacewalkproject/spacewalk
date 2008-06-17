-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_CHANNEL_DEL_TRIG" 
before delete on rhnChannel
for each row
declare
	cursor snapshots is
		select	snapshot_id id
		from	rhnSnapshotChannel
		where	channel_id = :old.id;
begin
	for snapshot in snapshots loop
		update rhnSnapshot
			set invalid = lookup_snapshot_invalid_reason('channel_removed')
			where id = snapshot.id;
		delete from rhnSnapshotChannel
			where snapshot_id = snapshot.id
				and channel_id = :old.id;
	end loop;
end;
ALTER TRIGGER "RHNSAT"."RHN_CHANNEL_DEL_TRIG" ENABLE
 
/
