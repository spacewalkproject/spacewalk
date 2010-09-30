-- oracle equivalent source sha1 ffb141fac8d9b3ad171e64c31c273d0acf32e261
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartDefaults.sql
create or replace function rhn_ksd_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ksd_mod_trig
before insert or update on rhnKickstartDefaults
for each row
execute procedure rhn_ksd_mod_trig_fun();

