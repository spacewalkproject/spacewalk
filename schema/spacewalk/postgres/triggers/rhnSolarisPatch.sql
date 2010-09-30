-- oracle equivalent source sha1 6f3b0977cca506853269685c8a02217d1a6e0bd5
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSolarisPatch.sql
create or replace function rhn_solaris_p_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_solaris_p_mod_trig
before insert or update on rhnSolarisPatch
for each row
execute procedure rhn_solaris_p_mod_trig_fun();


