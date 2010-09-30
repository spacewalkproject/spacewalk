-- oracle equivalent source sha1 87a873c26e281971ef96b9c4538a84d0eed17c2a
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnCpu.sql
create or replace function rhn_cpu_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;


create trigger
rhn_cpu_mod_trig
before insert or update on rhnCpu
for each row
execute procedure rhn_cpu_mod_trig_fun();
