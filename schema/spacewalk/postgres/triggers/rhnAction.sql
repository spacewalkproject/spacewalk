-- oracle equivalent source sha1 6dc8d8f6d6597aa44cbb6a972cd473a6be294bad
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnAction.sql
create or replace function rhn_action_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_action_mod_trig
before insert or update on rhnAction
for each row
execute procedure rhn_action_mod_trig_fun();

