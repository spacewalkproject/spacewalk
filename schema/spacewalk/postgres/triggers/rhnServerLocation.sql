-- oracle equivalent source sha1 b7d2285f30fdf5ebb3cdb3364e9e9f0f077173e5

create or replace function rhn_serverlocation_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_serverlocation_mod_trig
before insert or update on rhnServerLocation
for each row
execute procedure rhn_serverlocation_mod_trig_fun();


