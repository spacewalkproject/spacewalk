-- oracle equivalent source sha1 e0cbb410252705b3d43a58ca4c988a20376a7a20
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageGroup.sql
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

