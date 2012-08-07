-- oracle equivalent source sha1 d9b444ea8154b9bb7febc5d61ad8b68eab7bb0b2

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

