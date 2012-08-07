-- oracle equivalent source sha1 89d1824e803938af25dc914d5d9c5bc806911804

create or replace function rhn_solaris_psm_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_solaris_psm_mod_trig
before insert or update on rhnSolarisPatchSetMembers
for each row
execute procedure rhn_solaris_psm_mod_trig_fun();


