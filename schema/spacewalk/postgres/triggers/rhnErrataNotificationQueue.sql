-- oracle equivalent source sha1 71c579aa03b247561d70ba84001a8141c3c1f353

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
