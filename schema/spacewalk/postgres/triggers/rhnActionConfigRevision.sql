-- oracle equivalent source sha1 9214e6e78782535fb6d2b6ffeaf9672c892c8337

create or replace function rhn_actioncr_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actioncr_mod_trig
before insert or update on rhnActionConfigRevision
for each row
execute procedure rhn_actioncr_mod_trig_fun();

