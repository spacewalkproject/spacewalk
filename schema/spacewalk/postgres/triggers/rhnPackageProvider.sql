-- oracle equivalent source sha1 7e685c6ba0e689afdc25be816daa2cca1c745a50

create or replace function rhn_pkg_provider_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_provider_mod_trig
before insert or update on rhnPackageProvider
for each row
execute procedure rhn_pkg_provider_mod_trig_fun();
