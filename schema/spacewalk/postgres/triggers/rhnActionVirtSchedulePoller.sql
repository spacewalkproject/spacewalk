-- oracle equivalent source sha1 0e6a0cc6346fb1274942eee1d09828afcddf7aa7

create or replace function rhn_avsp_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avsp_mod_trig
before insert or update on rhnActionVirtSchedulePoller
for each row
execute procedure rhn_avsp_mod_trig_fun();
