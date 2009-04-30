create or replace function rhn_package_changelog_id_trig_fun() returns trigger as
$$
begin
	if new.is is null then
		select nextval('rhn_pkg_cl_id_seq') into new.id;
	end if;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_package_changelog_id_trig
before insert or update on rhnPackageChangelog
for each row
execute procedure rhn_package_changelog_id_trig_fun();


