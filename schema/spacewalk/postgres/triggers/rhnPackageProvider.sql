-- oracle equivalent source sha1 f9a6cf18dabbe42d3048b49d41447a7ddb81118d
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageProvider.sql
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
