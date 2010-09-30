-- oracle equivalent source sha1 8bdb8a8fd5c560e267443d97b652cbf8c11c943c
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnErrataKeywordTmp.sql
create or replace function rhn_errata_keywordtmp_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_errata_keywordtmp_mod_trig
before insert or update on rhnErrataKeywordTmp
for each row
execute procedure rhn_errata_keywordtmp_mod_trig_fun();
