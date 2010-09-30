-- oracle equivalent source sha1 ca6d8ea52e2ba08c3104de4da235105ea64e8dd2
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartSessionHistory.sql
create or replace function rhn_ks_sessionhist_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ks_sessionhist_mod_trig
before insert or update on rhnKickstartSessionHistory
for each row
execute procedure rhn_ks_sessionhist_mod_trig_fun();

