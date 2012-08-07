-- oracle equivalent source sha1 b1ee0841d4cb46725919c80367d2509e78584d98

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
