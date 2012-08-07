-- oracle equivalent source sha1 206ba65d78ace02b2440515d366ac08c38457cd9

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
