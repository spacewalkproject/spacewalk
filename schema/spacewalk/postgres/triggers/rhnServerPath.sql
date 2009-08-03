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


