-- oracle equivalent source sha1 594774999c21acf548930e4b30d915a9d5bfa8e5
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageArch.sql
create or replace function rhn_parch_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_parch_mod_trig
before insert or update on rhnPackageArch
for each row
execute procedure rhn_parch_mod_trig_fun();


