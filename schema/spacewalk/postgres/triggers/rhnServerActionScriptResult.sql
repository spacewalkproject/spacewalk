-- oracle equivalent source sha1 1cfac0cc1d49f04b21f9c77ebf40a7c2880cde6e

create or replace function rhn_serveras_result_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_serveras_result_mod_trig
before insert or update on rhnServerActionScriptResult
for each row
execute procedure rhn_serveras_result_mod_trig_fun();

