-- oracle equivalent source sha1 6e1f3554f050484c1a409401fd240d82da8756ba
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionVirtVcpu.sql
create or replace function rhn_avcpu_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avcpu_mod_trig
before insert or update on rhnActionVirtVcpu
for each row
execute procedure rhn_avcpu_mod_trig_fun();
