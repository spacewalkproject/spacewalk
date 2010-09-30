-- oracle equivalent source sha1 c042b89733e9ca2b806f2bf4ea971ea08a183f35
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageRequires.sql
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

