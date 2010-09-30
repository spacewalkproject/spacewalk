-- oracle equivalent source sha1 841c287c0b98af0e2234cce570dd68abf0ea2c8c
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerGroupNotes.sql
create or replace function rhn_servergroup_note_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_servergroup_note_mod_trig
before insert or update on rhnServerGroupNotes
for each row
execute procedure rhn_servergroup_note_mod_trig_fun();


