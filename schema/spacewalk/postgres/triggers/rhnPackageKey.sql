-- oracle equivalent source sha1 a616890e483eddc7528b75847de1489c95d166a5



create or replace function rhn_pkg_gpg_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_pkg_gpg_mod_trig
before insert or update on rhnPackageKey
for each row
execute procedure rhn_pkg_gpg_mod_trig_fun();

