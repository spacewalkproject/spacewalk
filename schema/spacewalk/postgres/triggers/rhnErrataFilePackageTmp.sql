-- oracle equivalent source sha1 2515e603796a0e897d5bb9653e4af51f19ee316d
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataFilePackageTmp.sql
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
