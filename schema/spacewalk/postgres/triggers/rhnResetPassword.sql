-- oracle equivalent source sha1 f00cc54ccbb2f6b94a62479b7eb069e50240a8ad

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
