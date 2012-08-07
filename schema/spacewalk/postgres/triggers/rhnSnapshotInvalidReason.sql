-- oracle equivalent source sha1 4de457e0ee108dc7299c625aaedddd7dd408c359

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


