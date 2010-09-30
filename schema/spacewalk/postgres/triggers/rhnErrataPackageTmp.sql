-- oracle equivalent source sha1 708fc42901b8151c38e571e9a9f0760091357df5
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataPackageTmp.sql
create or replace function rhn_errata_packagetmp_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_errata_packagetmp_mod_trig
before insert or update on rhnErrataPackageTmp
for each row
execute procedure rhn_errata_packagetmp_mod_trig_fun();
