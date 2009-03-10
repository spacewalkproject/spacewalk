create or replace function rhn_action_statusmod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_action_statusmod_trig
before insert or update on rhnActionStatus
for each row
execute procedure rhn_action_statusmod_trig_fun();
