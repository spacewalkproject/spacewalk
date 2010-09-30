-- oracle equivalent source sha1 b1124a977030f9135d3e962facc86da339d3ccde
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionConfigDateFile.sql
create or replace function rhn_actioncd_file_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actioncd_file_mod_trig
before insert or update on rhnActionConfigDateFile
for each row
execute procedure rhn_actioncd_file_mod_trig_fun();

