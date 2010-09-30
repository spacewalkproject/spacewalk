-- oracle equivalent source sha1 a263dead0c7ebc6f044fef752c970c64779eba89
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPushClient.sql
create or replace function rhn_pclient_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pclient_mod_trig
before insert or update on rhnPushClient
for each row
execute procedure rhn_pclient_mod_trig_fun();



