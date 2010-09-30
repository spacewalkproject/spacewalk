-- oracle equivalent source sha1 161e095a45e677ade54a2669de98ab8d923997dc
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartSessionState.sql
create or replace function rhn_ks_session_state_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ks_session_state_mod_trig
before insert or update on rhnKickstartSessionState
for each row
execute procedure rhn_ks_session_state_mod_trig_fun();

