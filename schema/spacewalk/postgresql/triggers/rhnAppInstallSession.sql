create or replace function rhn_appinst_session_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_appinst_session_mod_trig
before insert or update on rhnAppInstallSession
for each row
execute procedure rhn_appinst_session_mod_trig_fun();

