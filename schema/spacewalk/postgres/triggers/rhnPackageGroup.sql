create or replace function rhn_package_group_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_package_group_mod_trig
before insert or update on rhnPackageGroup
for each row
execute procedure rhn_package_group_mod_trig_fun();

