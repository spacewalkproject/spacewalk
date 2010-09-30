-- oracle equivalent source sha1 09565e59903079cacd1c27e5ecdc9866ccc0657b
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageChangeLog.sql
create or replace function rhn_package_changelog_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_package_changelog_mod_trig
before insert or update on rhnPackageChangelog
for each row
execute procedure rhn_package_changelog_mod_trig_fun();
