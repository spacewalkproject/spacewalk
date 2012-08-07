-- oracle equivalent source sha1 02d887ea206490642d23a1b1a0f469e1b458992e

create or replace function rhn_provstate_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_provstate_mod_trig
before insert or update on rhnProvisionState
for each row
execute procedure rhn_provstate_mod_trig_fun();
