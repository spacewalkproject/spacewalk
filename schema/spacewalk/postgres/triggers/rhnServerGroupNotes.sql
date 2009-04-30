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


