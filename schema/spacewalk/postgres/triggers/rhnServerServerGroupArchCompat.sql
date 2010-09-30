-- oracle equivalent source sha1 4301c057121ff46a021e6c9791da6f9dc9f52111
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerServerGroupArchCompat.sql
create or replace function rhn_ssg_ac_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_ssg_ac_mod_trig
before insert or update on rhnServerServerGroupArchCompat
for each row
execute procedure rhn_ssg_ac_mod_trig_fun();



