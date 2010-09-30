-- oracle equivalent source sha1 3f36195ea44a1a406b4d2c81155a0baf92f20f5d
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerActionScriptResult.sql
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

