-- oracle equivalent source sha1 8eb2e2eec7ea3dc3d8190657a04d2685104c2b77
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionKickstartFileList.sql
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

