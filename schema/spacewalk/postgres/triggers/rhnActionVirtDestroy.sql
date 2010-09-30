-- oracle equivalent source sha1 490f9c103c8efadf1783ee58c8fef35782459400
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionVirtDestroy.sql
create or replace function rhn_avd_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avd_mod_trig
before insert or update on rhnActionVirtDestroy
for each row
execute procedure rhn_avd_mod_trig_fun();

