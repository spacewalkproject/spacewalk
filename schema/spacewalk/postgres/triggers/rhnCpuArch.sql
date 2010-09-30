-- oracle equivalent source sha1 8313d1912dc72af3243e090a096ca480839e81bf
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnCpuArch.sql
create or replace function rhn_cpuarch_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;


create trigger
rhn_cpuarch_mod_trig
before insert or update on rhnCpuArch
for each row
execute procedure rhn_cpuarch_mod_trig_fun();
