-- oracle equivalent source sha1 9d8673e5c57a1e789db01a230755c021559243c2
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnArchTypeActions.sql
create or replace function rhn_archtypeacts_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_archtypeacts_mod_trig
before insert or update on rhnArchTypeActions
for each row
execute procedure rhn_archtypeacts_mod_trig_fun();
