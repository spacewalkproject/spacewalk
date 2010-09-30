-- oracle equivalent source sha1 3105a0fc193b5796b219d6889b642b4d3e1bf64b
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSatelliteServerGroup.sql
create or replace function rhn_satsg_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_satsg_mod_trig
before insert or update on rhnSatelliteServerGroup
for each row
execute procedure rhn_satsg_mod_trig_fun();

