create or replace rhn_errata_keyword_mod_trig_fun() returns trigger as
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
