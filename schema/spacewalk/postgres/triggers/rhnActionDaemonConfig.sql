-- oracle equivalent source sha1 7deea7dcb1be2e41603b4d778a7105deb00871f8

create or replace function rhn_actiondc_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actiondc_mod_trig
before insert or update on rhnActionDaemonConfig
for each row
execute procedure rhn_actiondc_mod_trig_fun();

