-- oracle equivalent source sha1 d31acf76ef7083f8551c74ccb8e2cce3cd3ffb30

create or replace function rhn_erratafiletmp_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_erratafiletmp_mod_trig
before insert or update on rhnErrataFileTmp
for each row
execute procedure rhn_erratafiletmp_mod_trig_fun();
