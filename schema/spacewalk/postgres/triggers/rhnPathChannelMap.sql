create or replace function rhn_path_channel_map_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_path_channel_map_mod_trig
before insert or update on rhnPathChannelMap
for each row
execute procedure rhn_path_channel_map_mod_trig_fun();


