-- oracle equivalent source sha1 81756cf45846fb384e909809fc9119524ba05726
-- retrieved from ./1240275246/0cdb617d92086ecea7530d9bece3b197c73432ea/schema/spacewalk/oracle/triggers/rhnActionKickstartGuest.sql
create or replace function rhn_actionks_xenguest_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actionks_xenguest_mod_trig
before insert or update on rhnActionKickstartGuest
for each row
execute procedure rhn_actionks_xenguest_mod_trig_fun();
