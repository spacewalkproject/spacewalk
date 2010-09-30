-- oracle equivalent source sha1 ae3bf273f52768af19c4aaf11506ce47eee3bbc4
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSnapshotConfigRevision.sql

create or replace function rhn_snapshotcr_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_snapshotcr_mod_trig
before insert or update on rhnSnapshotConfigRevision
for each row
execute procedure rhn_snapshotcr_mod_trig_fun();


