-- oracle equivalent source sha1 101364f734f18653d677736c15e33ccf6b92d21e

create or replace function rhn_avstart_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avstart_mod_trig
before insert or update on rhnActionVirtStart
for each row
execute procedure rhn_avstart_mod_trig_fun();

