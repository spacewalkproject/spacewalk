-- oracle equivalent source sha1 015e4e123542da6b3a03c6ed9968b49b9b3c50d1
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnPushDispatcher.sql
create or replace function rhn_pushdispatch_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pushdispatch_mod_trig
before insert or update on rhnPushDispatcher
for each row
execute procedure rhn_pushdispatch_mod_trig_fun();

