-- oracle equivalent source sha1 047e8b2a277255b12967934b8b72e0c1ca7cdcc0

create or replace function rhn_actionksfl_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actionksfl_mod_trig
before insert or update on rhnActionKickstartFileList
for each row
execute procedure rhn_actionksfl_mod_trig_fun();

