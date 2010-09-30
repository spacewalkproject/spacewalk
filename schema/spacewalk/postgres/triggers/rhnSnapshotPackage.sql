-- oracle equivalent source sha1 8b7196cb2eb281ec02fd49e56bfeac58c99a46fc
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSnapshotPackage.sql

create or replace function rhn_snapshotpkg_mod_trig_fun() returns trigger as
$$
begin
	update rhnSnapshot set modified = current_timestamp where id = new.snapshot_id;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_snapshotpkg_mod_trig
before insert or update on rhnSnapshotPackage
for each row
execute procedure rhn_snapshotpkg_mod_trig_fun();


