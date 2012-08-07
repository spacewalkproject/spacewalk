-- oracle equivalent source sha1 c2b782221f6963e6ced0e149a7d20733b4927fab


create or replace function rhn_snapshotsg_mod_trig_fun() returns trigger as
$$
begin
	update rhnSnapshot set modified = current_timestamp where id = new.snapshot_id;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_snapshotsg_mod_trig
before insert or update on rhnSnapshotServerGroup
for each row
execute procedure rhn_snapshotsg_mod_trig_fun();


