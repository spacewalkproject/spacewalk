-- oracle equivalent source sha1 eed046f831b6a814bdcf995dde898ce9174bab2a

create or replace function rhn_cperm_role_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cperm_role_mod_trig
before insert or update on rhnChannelPermissionRole
for each row
execute procedure rhn_cperm_role_mod_trig_fun();
