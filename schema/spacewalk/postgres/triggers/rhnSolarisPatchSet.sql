-- oracle equivalent source sha1 4dbd1e35bf7a3025183d9d4a9fda80c30ffffb68

create or replace function rhn_solaris_ps_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_solaris_ps_mod_trig
before insert or update on rhnSolarisPatchSet
for each row
execute procedure rhn_solaris_ps_mod_trig_fun();


