-- oracle equivalent source sha1 a955224feff9012625d0fb1b8d579c51bb8340d9
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionVirtSuspend.sql
create or replace function rhn_avsuspend_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avsuspend_mod_trig
before insert or update on rhnActionVirtSuspend
for each row
execute procedure rhn_avsuspend_mod_trig_fun();

