create or replace function rhn_beehive_path_map_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_beehive_path_map_mod_trig
before insert or update on rhnBeehivePathMap
for each row
execute procedure rhn_beehive_path_map_mod_trig_fun();
