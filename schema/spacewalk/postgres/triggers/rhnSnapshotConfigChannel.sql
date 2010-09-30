-- oracle equivalent source sha1 0fa832a43bf60403276c0a18deac64093db1862a
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSnapshotConfigChannel.sql
create or replace function rhn_snapshotcc_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_snapshotcc_mod_trig
before insert or update on rhnSnapshotConfigChannel
for each row
execute procedure rhn_snapshotcc_mod_trig_fun();


