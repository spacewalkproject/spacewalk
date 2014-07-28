-- oracle equivalent source sha1 022307e9d690010f443673170becac34edecc66a

create or replace function rhn_servernetwork_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_servernetwork_mod_trig
before insert or update on rhnServerNetwork
for each row
execute procedure rhn_servernetwork_mod_trig_fun();
