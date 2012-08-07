-- oracle equivalent source sha1 c7f7f19ddf701308deb229c8ca77caa1fb665a0c

create or replace function rhn_actioncd_file_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_actioncd_file_mod_trig
before insert or update on rhnActionConfigDateFile
for each row
execute procedure rhn_actioncd_file_mod_trig_fun();

