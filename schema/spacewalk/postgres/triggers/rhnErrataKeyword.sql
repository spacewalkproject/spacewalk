-- oracle equivalent source sha1 8d2f9e67ff9406962aa2c5a5fdb174888784f646
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataKeyword.sql
create or replace function rhn_errata_keyword_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_errata_keyword_mod_trig
before insert or update on rhnErrataKeyword
for each row
execute procedure rhn_errata_keyword_mod_trig_fun();
