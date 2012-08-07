-- oracle equivalent source sha1 96afef77ad9c09213a3b2a92e847f95305d8bb53

create or replace function rhn_efileptmp_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_efileptmp_mod_trig
before insert or update on rhnErrataFilePackageTmp
for each row
execute procedure rhn_efileptmp_mod_trig_fun();
