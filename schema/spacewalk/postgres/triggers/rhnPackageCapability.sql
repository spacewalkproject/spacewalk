-- oracle equivalent source sha1 237c45c0b272bcdf79ccf327277fcbcf94cee572

create or replace function rhn_pkg_capability_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_capability_mod_trig
before insert or update on rhnPackageCapability
for each row
execute procedure rhn_pkg_capability_mod_trig_fun();

