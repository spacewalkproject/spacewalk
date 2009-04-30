create or replace function rhn_user_res_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_user_res_mod_trig
before insert or update on rhnUserreserved
for each row
execute procedure rhn_user_res_mod_trig_fun();


