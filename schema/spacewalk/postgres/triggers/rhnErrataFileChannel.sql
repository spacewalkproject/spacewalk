-- oracle equivalent source sha1 e2c5cfbf96646e00d4eec7588707a949ed5b7046
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataFileChannel.sql
create or replace function rhn_efilec_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_efilec_mod_trig
before insert or update on rhnErrataFileChannel
for each row
execute procedure rhn_efilec_mod_trig_fun();
