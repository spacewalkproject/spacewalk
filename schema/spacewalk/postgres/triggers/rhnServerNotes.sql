-- oracle equivalent source sha1 3ff77de62a74ddeb1c4f1a0725a99ca55915986a

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

