-- oracle equivalent source sha1 c58104c2f0269dae7896edeeaf3e1759a049447e
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionVirtSetMemory.sql
create or replace function rhn_avsm_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avsm_mod_trig
before insert or update on rhnActionVirtSetMemory
for each row
execute procedure rhn_avsm_mod_trig_fun();

