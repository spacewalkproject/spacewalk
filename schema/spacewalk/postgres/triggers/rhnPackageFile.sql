-- oracle equivalent source sha1 a5c8a9ef63cc9810e3a988ecd75e3308c145d70c

create or replace function rhn_packagefile_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_packagefile_mod_trig
before insert or update on rhnPackageFile
for each row
execute procedure rhn_packagefile_mod_trig_fun();

