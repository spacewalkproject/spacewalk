-- oracle equivalent source sha1 4f91cf1fe59705084923fdcf7225a4f0e8644db2
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSnapshotChannel.sql
create or replace function rhn_snapchan_mod_trig_fun() returns trigger as
$$
begin
	update rhnSnapshot set modified = current_timestamp where id = new.snapshot_id;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_snapchan_mod_trig
before insert or update on rhnSnapshotChannel
for each row
execute procedure rhn_snapchan_mod_trig_fun();


