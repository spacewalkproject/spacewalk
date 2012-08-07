-- oracle equivalent source sha1 85ef934254ebdd7329a445b4adfd2b894dafee28

create or replace function rhn_errata_file_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_errata_file_mod_trig
before insert or update on rhnErrataFile
for each row
execute procedure rhn_errata_file_mod_trig_fun();
