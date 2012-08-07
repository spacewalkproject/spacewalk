-- oracle equivalent source sha1 b67b3b35dd2406faa9f63845b9743e5ef68fc431

create or replace function rhn_pkgsrc_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	new.last_modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkgsrc_mod_trig
before insert or update on rhnPackageSource
for each row
execute procedure rhn_pkgsrc_mod_trig_fun();

