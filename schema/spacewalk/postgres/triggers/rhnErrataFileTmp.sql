-- oracle equivalent source sha1 32ff1b98a0b28767881b1b6b759bc2cd64cbcc43
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataFileTmp.sql
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
