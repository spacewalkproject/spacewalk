create or replace function rhn_actionks_xenguest_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actionks_xenguest_mod_trig
before insert or update on rhnActionKickstartGuest
for each row
execute procedure rhn_actionks_xenguest_mod_trig_fun()

