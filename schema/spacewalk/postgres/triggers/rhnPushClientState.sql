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

