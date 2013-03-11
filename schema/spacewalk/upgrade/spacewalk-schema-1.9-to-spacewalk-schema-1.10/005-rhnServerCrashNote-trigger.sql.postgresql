-- oracle equivalent source sha1 179d3df6aed0424739cee44f486356ee9198b98b

create or replace function rhn_server_crash_note_mod_trig_fun() returns trigger as
$$
begin
    new.modified := current_timestamp;
    return new;
end;
$$ language plpgsql;

create trigger rhn_server_crash_note_mod_trig
before insert or update on rhnServerCrashNote
for each row
    execute procedure rhn_server_crash_note_mod_trig_fun();
