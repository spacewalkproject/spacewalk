-- oracle equivalent source sha1 f7967fad9f10c1697c42822bcf709a024102a68a
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionConfigDate.sql
create or replace function rhn_actioncd_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actioncd_mod_trig
before insert or update on rhnActionConfigDate
for each row
execute procedure rhn_actioncd_mod_trig_fun();

