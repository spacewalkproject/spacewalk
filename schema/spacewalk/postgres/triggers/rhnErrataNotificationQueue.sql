-- oracle equivalent source sha1 becd7501ebc344cad6e79d015f14250886b40044

create or replace function rhn_enqueue_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_enqueue_mod_trig
before insert or update on rhnErrataNotificationQueue
for each row
execute procedure rhn_enqueue_mod_trig_fun();
