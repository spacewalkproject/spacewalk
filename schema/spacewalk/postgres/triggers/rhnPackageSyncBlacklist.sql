-- oracle equivalent source sha1 900f5cf1ec139e01d463bdade7fd7f31042d74d4

create or replace function rhn_packagesyncbl_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_packagesyncbl_mod_trig
before insert or update on rhnPackageSyncBlacklist
for each row
execute procedure rhn_packagesyncbl_mod_trig_fun();

