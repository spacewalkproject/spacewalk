-- oracle equivalent source sha1 3feeb5739f9bab28417f5a16f67f1b31e411741f

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


