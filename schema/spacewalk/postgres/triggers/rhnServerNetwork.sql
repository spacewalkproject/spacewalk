-- oracle equivalent source sha1 5ae43465dd3ce2bcd14a08c1e0213c1536ae49bc

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
