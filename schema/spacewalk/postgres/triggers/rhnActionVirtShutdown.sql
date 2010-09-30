-- oracle equivalent source sha1 4ed687a64a4ad230352f885750e3e93ba8d65b86
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionVirtShutdown.sql
create or replace function rhn_avshutdown_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avshutdown_mod_trig
before insert or update on rhnActionVirtShutdown
for each row
execute procedure rhn_avshutdown_mod_trig_fun();

