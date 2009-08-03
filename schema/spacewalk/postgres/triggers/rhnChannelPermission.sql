create or replace function rhn_cperm_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cperm_mod_trig
before insert or update on rhnChannelPermission
for each row
execute procedure rhn_cperm_mod_trig_fun();
