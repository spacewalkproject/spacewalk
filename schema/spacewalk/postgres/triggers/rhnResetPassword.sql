-- oracle equivalent source sha1 fa27f1a2db02a80af213ee6397dd448c40dc61c0

create or replace function rhn_rstpwd_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_rstpwd_mod_trig
before insert or update on rhnResetPassword
for each row
execute procedure rhn_rstpwd_mod_trig_fun();
