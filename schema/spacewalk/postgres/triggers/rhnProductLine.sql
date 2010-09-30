-- oracle equivalent source sha1 04baeb8042572c260b4489edeae5bd0a5739d77c
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnProductLine.sql
create or replace function rhn_prod_line_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	new.last_modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_prod_line_mod_trig
before insert or update on rhnProductLine
for each row
execute procedure rhn_prod_line_mod_trig_fun();

