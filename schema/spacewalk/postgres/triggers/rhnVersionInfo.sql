-- oracle equivalent source sha1 da144423531fc60b2a67a2ba15d358a76b1abc63

create or replace function rhn_versioninfo_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;

 	return new;
end;
$$ language plpgsql;

create trigger
rhn_versioninfo_mod_trig
before insert or update on rhnVersionInfo
for each row
execute procedure rhn_versioninfo_mod_trig_fun();


