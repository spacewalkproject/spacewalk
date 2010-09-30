-- oracle equivalent source sha1 1724d00398fcd1ec0172929dd956dd5dec892dc4
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataFile.sql
create or replace function rhn_errata_file_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_errata_file_mod_trig
before insert or update on rhnErrataFile
for each row
execute procedure rhn_errata_file_mod_trig_fun();
