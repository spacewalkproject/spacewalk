-- oracle equivalent source sha1 ee7ee108ed5982d36f0221c3c542ebdc2433c391
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPushClientState.sql
create or replace function rhn_pclient_state_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pclient_state_mod_trig
before insert or update on rhnPushClientState
for each row
execute procedure rhn_pclient_state_mod_trig_fun();

