create or replace function rhn_cfstate_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cfstate_mod_trig
before insert or update on rhnConfigFileState
for each row
execute procedure rhn_cfstate_mod_trig_fun();
