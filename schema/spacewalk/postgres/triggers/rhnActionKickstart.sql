-- oracle equivalent source sha1 5c156e8c45e04fd50fcd9a8d3872281722a34f03
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionKickstart.sql
create or replace function rhn_actionks_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger       
rhn_actionks_mod_trig
before insert or update on rhnActionKickstart
for each row
execute procedure rhn_actionks_mod_trig_fun();
