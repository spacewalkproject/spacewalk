-- oracle equivalent source sha1 4771eb747bccbf036dcc8b78ae4c8d2778eb1a23
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPackageFile.sql
create or replace function rhn_packagefile_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_packagefile_mod_trig
before insert or update on rhnPackageFile
for each row
execute procedure rhn_packagefile_mod_trig_fun();

