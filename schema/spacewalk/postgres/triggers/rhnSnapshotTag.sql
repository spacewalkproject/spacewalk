-- oracle equivalent source sha1 47087d8f05fbb6ecd851f77ea686d94504c6b60e
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnSnapshotTag.sql
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


