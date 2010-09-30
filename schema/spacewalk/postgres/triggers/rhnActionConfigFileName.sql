-- oracle equivalent source sha1 e5568b1a445bd95fe13c2aed19e5b9b44bf39cba
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnActionConfigFileName.sql
create or replace function rhn_actioncf_name_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actioncf_name_mod_trig
before insert or update on rhnActionConfigFileName
for each row
execute procedure rhn_actioncf_name_mod_trig_fun();

