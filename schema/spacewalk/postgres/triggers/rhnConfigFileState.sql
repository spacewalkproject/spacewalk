-- oracle equivalent source sha1 df359eb4bf3d508aaef159f63bad54c62fd83f3b
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnConfigFileState.sql
create or replace function rhn_cfstate_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cfstate_mod_trig
before insert or update on rhnConfigFileState
for each row
execute procedure rhn_cfstate_mod_trig_fun();
