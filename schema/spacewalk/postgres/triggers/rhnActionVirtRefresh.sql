-- oracle equivalent source sha1 2f84f56ce8f6b1883f5cdc9d014c0960ef07ca4d
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionVirtRefresh.sql
create or replace function rhn_avrefresh_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avrefresh_mod_trig
before insert or update on rhnActionVirtRefresh
for each row
execute procedure rhn_avrefresh_mod_trig_fun();

