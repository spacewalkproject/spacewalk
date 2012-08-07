-- oracle equivalent source sha1 0f47d43fc3a6d84fbb0adba15efa963c61f118c5

create or replace function rhn_efilep_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_efilep_mod_trig
before insert or update on rhnErrataFilePackage
for each row
execute procedure rhn_efilep_mod_trig_fun();

