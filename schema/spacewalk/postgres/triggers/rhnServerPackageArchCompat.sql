-- oracle equivalent source sha1 4eff3a9b0dbbeeb7519b5148f0f1cdd5e0275363

create or replace function rhn_sp_ac_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sp_ac_mod_trig
before insert or update on rhnServerPackageArchCompat
for each row
execute procedure rhn_sp_ac_mod_trig_fun();


