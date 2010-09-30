-- oracle equivalent source sha1 8498ed6203a3d6c7344769c2e483cf052c1a3536
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerHistory.sql

create or replace function rhn_serverhistory_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_serverhistory_mod_trig
before insert or update on rhnServerHistory
for each row
execute procedure rhn_serverhistory_mod_trig_fun();


