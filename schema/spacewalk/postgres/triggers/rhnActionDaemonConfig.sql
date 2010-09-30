-- oracle equivalent source sha1 3bf7b27327a8604e81264d698f643b524f77a208
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionDaemonConfig.sql
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

