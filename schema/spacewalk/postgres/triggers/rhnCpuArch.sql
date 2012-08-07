-- oracle equivalent source sha1 fe2006bf0fbf9bef3dc1416a9e45620ac043817f

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
