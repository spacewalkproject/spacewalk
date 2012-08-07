-- oracle equivalent source sha1 f6dcc1287bbb591f8a41880f5bb041d6c99e53b6

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



