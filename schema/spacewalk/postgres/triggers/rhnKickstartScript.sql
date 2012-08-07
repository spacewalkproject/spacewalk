-- oracle equivalent source sha1 1da5f190bac54d6b3664f6b0a75fb1287052f901

create or replace function rhn_ksscript_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_ksscript_mod_trig
before insert or update on rhnKickstartScript
for each row
execute procedure rhn_ksscript_mod_trig_fun();

