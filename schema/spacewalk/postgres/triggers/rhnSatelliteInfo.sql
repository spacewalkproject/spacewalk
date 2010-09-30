-- oracle equivalent source sha1 e65cad4a55d1a418aa4b665ddbf21c6663d26a1c
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSatelliteInfo.sql
create or replace function rhn_satellite_info_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_satellite_info_mod_trig
before insert or update on rhnSatelliteInfo
for each row
execute procedure rhn_satellite_info_mod_trig_fun();


