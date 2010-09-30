-- oracle equivalent source sha1 44603082e6be8dcc8cc118fb16fcbc0da132665d
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataFilePackageSource.sql
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
