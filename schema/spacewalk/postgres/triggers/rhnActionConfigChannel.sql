-- oracle equivalent source sha1 fe77550994d31ad6b089676f396c07070c0ea97b
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionConfigChannel.sql
create or replace function rhn_actioncc_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actioncc_mod_trig
before insert or update on rhnActionConfigChannel
for each row
execute procedure rhn_actioncc_mod_trig_fun();

