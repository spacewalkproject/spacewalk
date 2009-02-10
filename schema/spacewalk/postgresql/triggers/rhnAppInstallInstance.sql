create or replace function rhn_appinst_istance_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_appinst_istance_mod_trig
before insert or update on rhnAppInstallInstance
for each row
execute procedure rhn_action_mod_trig_fun();
