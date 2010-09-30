-- oracle equivalent source sha1 5d17c408b0f22db5392191e0e143d430010bffa7
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageConflicts.sql
create or replace function rhn_pkg_conflicts_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_conflicts_mod_trig
before insert or update on rhnPackageConflicts
for each row
execute procedure rhn_pkg_conflicts_mod_trig_fun();

