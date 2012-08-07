-- oracle equivalent source sha1 d01c373c8f7b9338e537724b271358b8550042ba

create or replace function rhn_template_cat_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_template_cat_mod_trig
before insert or update on rhnTemplateCategory
for each row
execute procedure rhn_template_cat_mod_trig_fun();


