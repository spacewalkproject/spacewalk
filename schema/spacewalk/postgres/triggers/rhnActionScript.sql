-- oracle equivalent source sha1 7c4c82b5616a384aa9b439d1e4a43d17cd2e8e58
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnActionScript.sql
create or replace function rhn_actscript_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actscript_mod_trig
before insert or update on rhnActionScript
for each row
execute procedure rhn_actscript_mod_trig_fun();
