-- oracle equivalent source sha1 145d6c13e5932088c7ec0279a64dc02f89d6984e

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
