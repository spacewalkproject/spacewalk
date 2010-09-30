-- oracle equivalent source sha1 c4039e8e39af65dd3306ef7301ef902273bb7445
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionConfigRevision.sql
create or replace function rhn_actioncr_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actioncr_mod_trig
before insert or update on rhnActionConfigRevision
for each row
execute procedure rhn_actioncr_mod_trig_fun();

