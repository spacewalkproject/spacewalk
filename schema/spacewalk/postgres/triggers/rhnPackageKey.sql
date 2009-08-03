

create or replace function rhn_pkg_gpg_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_gpg_mod_trig
before insert or update on rhnPackageKey
for each row
execute procedure rhn_pkg_gpg_mod_trig_fun();

