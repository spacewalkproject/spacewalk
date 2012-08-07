-- oracle equivalent source sha1 6f4a1d50ac8c737644545b5baaf38a8656ed1df4

create or replace function rhn_serverpath_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_serverpath_mod_trig
before insert or update on rhnServerPath
for each row
execute procedure rhn_serverpath_mod_trig_fun();


