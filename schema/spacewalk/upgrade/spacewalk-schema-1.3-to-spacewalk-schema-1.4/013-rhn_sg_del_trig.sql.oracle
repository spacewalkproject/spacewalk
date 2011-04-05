
create or replace trigger
rhn_sg_del_trig
before delete on rhnServerGroup
for each row
declare
	cursor snapshots is
		select	snapshot_id id
		from	rhnSnapshotServerGroup
		where	server_group_id = :old.id
		order by snapshot_id;
begin
	for snapshot in snapshots loop
		update rhnSnapshot
			set invalid = lookup_snapshot_invalid_reason('sg_removed')
			where id = snapshot.id;
		delete from rhnSnapshotServerGroup
			where snapshot_id = snapshot.id
				and server_group_id = :old.id;
	end loop;
end;
/
show errors

