-- oracle equivalent source sha1 4017c29f344c6e7115ef4975e36312c5e0d0d045
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnActionConfigRevisionResult.sql
create or replace function rhn_actioncfr_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actioncfr_mod_trig
before insert or update on rhnActionConfigRevisionResult
for each row
execute procedure rhn_actioncfr_mod_trig_fun();
