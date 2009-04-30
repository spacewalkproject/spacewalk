create or replace function rhn_ss_tag_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_ss_tag_mod_trig
before insert or update on rhnSnapshotTag
for each row
execute procedure rhn_ss_tag_mod_trig_fun();


