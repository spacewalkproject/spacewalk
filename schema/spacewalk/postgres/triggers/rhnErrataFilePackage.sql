-- oracle equivalent source sha1 a0c47c6506f3c4fc977b65ce450b0919375d12d3
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataFilePackage.sql
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

