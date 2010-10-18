-- oracle equivalent source sha1 7464f1dde73a7ddff87cfc843decae77a0441cc9
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageChangeLog_triggers.sql
create or replace function rhn_package_changelog_id_trig_fun() returns trigger as
$$
begin
	if new.id is null then
		new.id := nextval('rhn_pkg_cl_id_seq');
	end if;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_package_changelog_id_trig
before insert or update on rhnPackageChangelog
for each row
execute procedure rhn_package_changelog_id_trig_fun();


