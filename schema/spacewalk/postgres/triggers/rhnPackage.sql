create or replace function rhn_package_mod_trig_fun() returns trigger as
$$
begin
	
	if new.last_modified = old.last_modified then
		new.last_modified :=current_timestamp;
	end if;

	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_package_mod_trig
before insert or update on rhnPackage
for each row
execute procedure rhn_package_mod_trig_fun();

