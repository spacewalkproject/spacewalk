-- oracle equivalent source sha1 3f99bdb8f4c08e5f0c4b51c6c883bdb512938143

create or replace function rhn_pkg_provides_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_provides_mod_trig
before insert or update on rhnPackageProvides
for each row
execute procedure rhn_pkg_provides_mod_trig_fun();
