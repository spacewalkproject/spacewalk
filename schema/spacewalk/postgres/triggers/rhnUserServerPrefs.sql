-- oracle equivalent source sha1 c09178c7818316762cc91e4476a858d4e8ae51f7

create or replace function rhn_u_s_prefs_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
	new.value := upper (new.value);
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_u_s_prefs_mod_trig
before insert or update on rhnUserServerPrefs
for each row
execute procedure rhn_u_s_prefs_mod_trig_fun();


