-- oracle equivalent source sha1 fa5643bd5e5e745ffdf3c40431e6948adbae18ad
-- retrieved from ./1240275246/0cdb617d92086ecea7530d9bece3b197c73432ea/schema/spacewalk/oracle/triggers/rhnActionVirtSchedulePoller.sql
create or replace function rhn_avsp_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avsp_mod_trig
before insert or update on rhnActionVirtSchedulePoller
for each row
execute procedure rhn_avsp_mod_trig_fun();
