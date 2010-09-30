-- oracle equivalent source sha1 e2d88612f4b230e06dea4e7bb115cad5d0594d72
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerLocation.sql
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


