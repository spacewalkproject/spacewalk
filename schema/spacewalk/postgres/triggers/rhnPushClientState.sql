-- oracle equivalent source sha1 79a0c20aa01b49bd5c9338796be1a5325d259d5b

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

