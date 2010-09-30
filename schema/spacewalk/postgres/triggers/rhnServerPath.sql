-- oracle equivalent source sha1 310d732e894caccd8744fdadaff7ab0b12679017
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerPath.sql
create or replace function rhn_serverpath_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_serverpath_mod_trig
before insert or update on rhnServerPath
for each row
execute procedure rhn_serverpath_mod_trig_fun();


