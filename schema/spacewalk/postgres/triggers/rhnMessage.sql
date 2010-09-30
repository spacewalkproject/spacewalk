-- oracle equivalent source sha1 c4d2129d49a0db34d1642555f733ceb2a293c83d
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnMessage.sql

create or replace function rhn_m_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_m_mod_trig
before insert or update on rhnMessage
for each row
execute procedure rhn_m_mod_trig_fun();

