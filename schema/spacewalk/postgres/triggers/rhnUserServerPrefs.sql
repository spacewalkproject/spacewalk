-- oracle equivalent source sha1 f3aab49eef869cf4839b9809b21e0d528cecf45e
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnUserServerPrefs.sql
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


