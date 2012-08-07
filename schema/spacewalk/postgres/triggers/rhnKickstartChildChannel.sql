-- oracle equivalent source sha1 59b4d26cfb41871e30e154e48ddd125f94617fdf

create or replace function rhn_ks_cc_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ks_cc_mod_trig
before insert or update on rhnKickstartChildChannel
for each row
execute procedure rhn_ks_cc_mod_trig_fun();

