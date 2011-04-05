-- oracle equivalent source sha1 77c918b95b546743a73f5971eedc38dbd0a768c5

create or replace function rhn_sg_del_trig_fun() returns trigger
as
$$
declare
        snapshot_curs_id	numeric;
begin
	for snapshot_curs_id in
                select  snapshot_id
                from    rhnSnapshotServerGroup
                where   server_group_id = old.id
                order by snapshot_id
	loop
		update rhnSnapshot
                        set invalid = lookup_snapshot_invalid_reason('sg_removed')
                        where id = snapshot_curs_id;
                delete from rhnSnapshotServerGroup
                        where snapshot_id = snapshot_curs_id
                                and server_group_id = old.id;
		
	end loop;

	return old;
 end;
 $$
 language plpgsql;

