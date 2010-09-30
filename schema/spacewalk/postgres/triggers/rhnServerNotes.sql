-- oracle equivalent source sha1 75b03aa370e20fea375d318dfec1a70f4be2c737
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerNotes.sql
create or replace function rhn_servernotes_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_servernotes_mod_trig
before insert or update on rhnServerNotes
for each row
execute procedure rhn_servernotes_mod_trig_fun();

