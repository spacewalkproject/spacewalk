create or replace rhn_efilep_mod_trig_fun() returns trigger as
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

