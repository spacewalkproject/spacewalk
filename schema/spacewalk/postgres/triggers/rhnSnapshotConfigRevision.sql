-- oracle equivalent source sha1 cdfc1f733ba89392e767d9edfd788936aaa8432a


create or replace function rhn_snapshotcr_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_snapshotcr_mod_trig
before insert or update on rhnSnapshotConfigRevision
for each row
execute procedure rhn_snapshotcr_mod_trig_fun();


