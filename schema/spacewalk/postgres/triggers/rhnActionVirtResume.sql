-- oracle equivalent source sha1 c5436c89c71a79ccd879cb1c68fcc97f7aeec800
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionVirtResume.sql
create or replace function rhn_avresume_mod_trig_fun()  returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_avresume_mod_trig
before insert or update on rhnActionVirtResume
for each row
execute procedure rhn_avresume_mod_trig_fun();

