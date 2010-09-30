-- oracle equivalent source sha1 aace56c46cb0f70cb2e1bf379487b8a159d3be15
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSnapshotServerGroup.sql

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


