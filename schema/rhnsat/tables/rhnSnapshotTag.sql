--
-- $Id$
--/

create table
rhnSnapshotTag
(
	snapshot_id	number
			constraint rhn_st_ssid_nn not null
			constraint rhn_st_ssid_fk
				references rhnSnapshot(id)
				on delete cascade,
	tag_id          number
			constraint rhn_st_tid_nn not null
			constraint rhn_st_tid_fk
				references rhnTag(id),
	server_id	number
			constraint rhn_st_sid_fk
				references rhnServer(id),
	created		date default (sysdate)
			constraint rhn_st_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_st_modified_nn not null
);

create unique index rhn_ss_tag_ssid_tid_uq
    	on rhnSnapshotTag(snapshot_id, tag_id);

create unique index rhn_ss_tag_sid_tid_uq
    	on rhnSnapshotTag(server_id, tag_id);
	
create index rhn_ss_tag_tid_ssid_idx
    	on rhnSnapshotTag(tag_id, snapshot_id);

create index rhn_ss_tag_tid_sid_idx
    	on rhnSnapshotTag(tag_id, server_id);

create or replace trigger
rhn_ss_tag_mod_trig
before insert or update on rhnSnapshotTag
for each row
begin
        :new.modified := sysdate;
end;
/
show errors


-- $Log$
-- Revision 1.4  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.3  2004/01/15 21:25:50  pjones
-- bugzilla: none (Joe is filing one now, maybe?)
-- Fix deletion of snapshots
-- Fix deletion of channels once a snapshot has been taken of a server
--   in said channel
--
-- Revision 1.2  2003/10/16 14:23:33  bretm
-- bugzilla:  107189
--
-- o  added server_id to rhnSnapshotTag
-- o  added lookup_tag(org_id, tagname)
--
-- Revision 1.1  2003/10/15 20:29:53  bretm
-- bugzilla:  107189
--
-- 1st pass at snapshot tagging schema
--
