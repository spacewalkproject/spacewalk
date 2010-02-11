-- created by Oraschemadoc Fri Jan 22 13:40:55 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_CONFCHAN_DEL_TRIG"
before delete on rhnConfigChannel
for each row
declare
	cursor snapshots is
		select	snapshot_id id
		from	rhnSnapshotConfigChannel
		where	config_channel_id = :old.id;
begin
	for snapshot in snapshots loop
		update rhnSnapshot
			set invalid = lookup_snapshot_invalid_reason('cc_removed')
			where id = snapshot.id;
		delete from rhnSnapshotConfigChannel
			where snapshot_id = snapshot.id
				and config_channel_id = :old.id;
	end loop;
end;
ALTER TRIGGER "SPACEWALK"."RHN_CONFCHAN_DEL_TRIG" ENABLE
 
/
