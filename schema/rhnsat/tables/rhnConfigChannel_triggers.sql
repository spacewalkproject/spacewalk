--
-- $Id$
--

create or replace trigger
rhn_confchan_mod_trig
before insert or update on rhnConfigChannel
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

create or replace trigger
rhn_confchan_del_trig
before delete on rhnConfigChannel
for each row
declare
	cursor snapshots is
		select	snapshot_id id
		from	rhnSnapshotConfigChannel
		where	config_channel_id = :old.id;
begin
	for snapshot in snapshots loop
		update rhnSnapshot
			set invalid = lookup_snapshot_invalid_reason('cc_removed')
			where id = snapshot.id;
		delete from rhnSnapshotConfigChannel
			where snapshot_id = snapshot.id
				and config_channel_id = :old.id;
	end loop;
end;
/
show errors

--
-- $Log$
-- Revision 1.3  2003/12/18 16:29:10  pjones
-- bugzilla: none -- the trigger way won't work, back it out
--
