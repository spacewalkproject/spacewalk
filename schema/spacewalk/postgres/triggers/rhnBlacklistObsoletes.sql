-- oracle equivalent source sha1 f2173f3c25e95db9dde31b15c4a4c965a504503c
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnBlacklistObsoletes.sql
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

