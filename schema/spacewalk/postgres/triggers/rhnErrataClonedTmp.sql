-- oracle equivalent source sha1 ff4b616f51bf57a85111f7b92b6b0d6ef2bd12d4
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnErrataClonedTmp.sql
create or replace function rhn_eclonedtmp_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_eclonedtmp_mod_trig
before insert or update on rhnErrataClonedTmp
for each row
execute procedure rhn_eclonedtmp_mod_trig_fun();
