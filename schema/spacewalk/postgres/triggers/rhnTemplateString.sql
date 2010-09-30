-- oracle equivalent source sha1 0a8cac173ce3222424db045850169a8ee0eeecfa
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnTemplateString.sql
create or replace function rhn_template_str_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_template_str_mod_trig
before insert or update on rhnTemplateString
for each row
execute procedure rhn_template_str_mod_trig_fun();


