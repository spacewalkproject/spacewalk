create or replace function rhn_conffile_fail_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_conffile_fail_mod_trig
before insert or update on rhnConfigFileFailure
for each row
execute procedure rhn_conffile_fail_mod_trig_fun();

