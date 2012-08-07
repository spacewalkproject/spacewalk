-- oracle equivalent source sha1 392c3b9a0837a478e4428c3fa92cccf9b7d1bc1c

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
