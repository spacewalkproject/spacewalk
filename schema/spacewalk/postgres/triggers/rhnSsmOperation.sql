create or replace function rhn_ssmop_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_ssmop_mod_trig
before insert or update on rhnSsmOperation
for each row
execute procedure rhn_ssmop_mod_trig_fun();


