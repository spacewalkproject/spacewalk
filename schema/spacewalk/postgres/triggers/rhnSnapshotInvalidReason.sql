-- oracle equivalent source sha1 2963dd5f644580e960b45c4fc070f1c3c3477856
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSnapshotInvalidReason.sql
create or replace function rhn_ssinvalid_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_ssinvalid_mod_trig
before insert or update on rhnSnapshotInvalidReason
for each row
execute procedure rhn_ssinvalid_mod_trig_fun();


