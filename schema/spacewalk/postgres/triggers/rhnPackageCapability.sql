-- oracle equivalent source sha1 b13e3b2224175c3f068f068e60c3f6cedcdfef55
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageCapability.sql
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

