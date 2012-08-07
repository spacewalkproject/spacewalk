-- oracle equivalent source sha1 12c956a1bb831a306aac5b039557b66b832cfd3a

create or replace function rhn_ram_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	       
	return new;
end;
$$ language plpgsql;

create trigger
rhn_ram_mod_trig
before insert or update on rhnRam
for each row
execute procedure rhn_ram_mod_trig_fun();


