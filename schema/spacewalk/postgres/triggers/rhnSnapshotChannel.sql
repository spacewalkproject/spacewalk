-- oracle equivalent source sha1 a212e3c415c5c26ffeaa354438acbd287ef6dc96

create or replace function rhn_snapchan_mod_trig_fun() returns trigger as
$$
begin
	update rhnSnapshot set modified = current_timestamp where id = new.snapshot_id;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_snapchan_mod_trig
before insert or update on rhnSnapshotChannel
for each row
execute procedure rhn_snapchan_mod_trig_fun();


