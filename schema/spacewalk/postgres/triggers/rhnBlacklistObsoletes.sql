create or replace function rhn_bl_obs_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_bl_obs_mod_trig
before insert or update on rhnBlacklistObsoletes
for each row
execute procedure rhn_bl_obs_mod_trig_fun();

