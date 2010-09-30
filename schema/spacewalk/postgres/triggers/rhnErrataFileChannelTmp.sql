-- oracle equivalent source sha1 61d693002c6edfb93450d58d2375154b0e293cbb
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataFileChannelTmp.sql
create or replace function rhn_efilectmp_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_efilectmp_mod_trig
before insert or update on rhnErrataFileChannelTmp
for each row
execute procedure rhn_efilectmp_mod_trig_fun();
