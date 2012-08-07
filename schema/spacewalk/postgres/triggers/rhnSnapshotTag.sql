-- oracle equivalent source sha1 f256acea9e4362fa90c950ed3b83001f203b2424

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


