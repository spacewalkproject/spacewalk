-- oracle equivalent source sha1 b26e9fe171e2aea57ac1eb21fdd031ba1d9a272e
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnTextMessage.sql
create or replace function rhn_tm_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_tm_mod_trig
before insert or update on rhnTextMessage
for each row
execute procedure rhn_tm_mod_trig_fun();


