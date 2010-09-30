-- oracle equivalent source sha1 e0f96d1420e9320caa2010df02f4a3fb57dc8130
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPathChannelMap.sql
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


