-- oracle equivalent source sha1 35de3a81518b79e5824ac32510028da1412978dc
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageKeyType.sql
create or replace function rhn_pkg_key_type_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_key_type_mod_trig
before insert or update on rhnPackageKeyType
for each row
execute procedure rhn_pkg_key_type_mod_trig_fun();

