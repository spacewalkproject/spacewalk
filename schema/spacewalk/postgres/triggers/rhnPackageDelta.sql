-- oracle equivalent source sha1 73137bfd83c679369ff85a2bf61b389105d3b14f
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageDelta.sql

create or replace function rhn_packagedelta_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_packagedelta_mod_trig
before insert or update on rhnPackageDelta
for each row
execute procedure rhn_packagedelta_mod_trig_fun();

