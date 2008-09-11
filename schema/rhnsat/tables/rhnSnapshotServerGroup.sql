--
-- $Id$
--

create table
rhnSnapshotServerGroup
(
	snapshot_id		number
				constraint rhn_snapshotsg_sid_nn not null
				constraint rhn_snapshotsg_sid_fk
					references rhnSnapshot(id)
					on delete cascade,
	server_group_id		number
				constraint rhn_snapshotsg_sgid_nn not null
				constraint rhn_snapshotsg_sgid_fk
					references rhnServerGroup(id)
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_snapshotsg_sid_sgid_uq
	on rhnSnapshotServerGroup( snapshot_id, server_group_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_snapshotsg_sgid_idx
	on rhnSnapshotServerGroup( server_group_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_snapshotsg_mod_trig
before insert or update on rhnSnapshotServerGroup
for each row
begin
	update rhnSnapshot set modified = sysdate where id = :new.snapshot_id;
end;
/
show errors
				
--
-- $Log$
-- Revision 1.5  2004/01/15 21:25:50  pjones
-- bugzilla: none (Joe is filing one now, maybe?)
-- Fix deletion of snapshots
-- Fix deletion of channels once a snapshot has been taken of a server
--   in said channel
--
-- Revision 1.4  2003/10/07 20:49:18  pjones
-- bugzilla: 106188
--
-- snapshot invalidation
--
-- Revision 1.3  2003/10/02 16:36:07  pjones
-- bugzilla: none
--
-- fix extra excludes, add another dep for rhn_server
--
-- Revision 1.2  2003/09/26 17:53:40  cturner
-- fix typos and thinkos for the qa push
--
-- Revision 1.1  2003/09/15 21:01:08  pjones
-- bugzilla: none
--
-- tables for snapshot support; still need to write the code to build a snapshot
-- from a working system, but that's pretty simple.
--
