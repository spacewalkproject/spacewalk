create or replace function rhn_tag_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_tag_mod_trig
before insert or update on rhnTag
for each row
execute procedure rhn_tag_mod_trig_fun();


