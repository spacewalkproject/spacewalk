-- oracle equivalent source sha1 678fe04d944e64ed956cb0157eb1e893a73f7e79

create or replace function rhn_erratatmp_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        new.last_modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_erratatmp_mod_trig
before insert or update on rhnErrataTmp
for each row
execute procedure rhn_erratatmp_mod_trig_fun();

