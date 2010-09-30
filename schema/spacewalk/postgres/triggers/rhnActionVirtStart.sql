-- oracle equivalent source sha1 910a3eb5e364bc14b7b771b27b84cc8dc895976a
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionVirtStart.sql
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

