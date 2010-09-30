-- oracle equivalent source sha1 a9b95bf06190d66fa58e373cbcfc6d07feff3e9d
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnTemplateCategory.sql
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


