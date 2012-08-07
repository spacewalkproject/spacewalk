-- oracle equivalent source sha1 03b6415f7dc14db1b013755f81388515713f7924

create or replace function rhn_efileps_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_efileps_mod_trig
before insert or update on rhnErrataFilePackageSource
for each row
execute procedure rhn_efileps_mod_trig_fun();
