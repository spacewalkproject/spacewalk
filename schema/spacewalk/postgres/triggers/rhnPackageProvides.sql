-- oracle equivalent source sha1 54e0cb0360a523e434efbae49e99c9e49ae17049
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageProvides.sql
create or replace function rhn_pkg_provides_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_provides_mod_trig
before insert or update on rhnPackageProvides
for each row
execute procedure rhn_pkg_provides_mod_trig_fun();
