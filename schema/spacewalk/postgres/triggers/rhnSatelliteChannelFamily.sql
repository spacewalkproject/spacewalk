-- oracle equivalent source sha1 248736eb9b98094c630afcc108f9ad63382d20a6
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSatelliteChannelFamily.sql
create or replace function rhn_sat_cf_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_sat_cf_mod_trig
before insert or update on rhnSatelliteChannelFamily
for each row
execute procedure rhn_sat_cf_mod_trig_fun();


