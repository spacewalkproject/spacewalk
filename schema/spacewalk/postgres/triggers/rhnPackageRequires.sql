-- oracle equivalent source sha1 fc6c40e182879a8432f75b91ecd04badd00322d8

create or replace function rhn_pkg_requires_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_requires_mod_trig
before insert or update on rhnPackageRequires
for each row
execute procedure rhn_pkg_requires_mod_trig_fun();

