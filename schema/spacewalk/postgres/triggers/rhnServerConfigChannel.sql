-- oracle equivalent source sha1 2a9c8e06bac466feb34dc04b8dc09b25b41608db
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerConfigChannel.sql
create or replace function rhn_servercc_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_servercc_mod_trig
before insert or update on rhnServerConfigChannel
for each row
execute procedure rhn_servercc_mod_trig_fun();


