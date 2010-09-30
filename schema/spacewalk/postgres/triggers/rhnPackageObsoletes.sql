-- oracle equivalent source sha1 903bf7f1be0bb2ec1c8a03f732c9d86b2e5c145e
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageObsoletes.sql

create or replace function rhn_pkg_obsoletes_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_obsoletes_mod_trig
before insert or update on rhnPackageObsoletes
for each row
execute procedure rhn_pkg_obsoletes_mod_trig_fun();


