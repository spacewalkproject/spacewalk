-- oracle equivalent source sha1 0b096259670da7c8258b9f818eb36e7b57724c69

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


