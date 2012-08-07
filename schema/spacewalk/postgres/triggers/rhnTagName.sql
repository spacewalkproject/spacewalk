-- oracle equivalent source sha1 c6a9455168bfd1c75f3050c6726e8012df849508

create or replace function rhn_tn_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_tn_mod_trig
before insert or update on rhnTagName
for each row
execute procedure rhn_tn_mod_trig_fun();


