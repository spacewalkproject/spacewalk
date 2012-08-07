-- oracle equivalent source sha1 d59c67812794227251b2e2f3bce2adaa526ced34

create or replace function rhn_ksd_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ksd_mod_trig
before insert or update on rhnKickstartDefaults
for each row
execute procedure rhn_ksd_mod_trig_fun();

