--
-- $Id$
--

create table
rhnSnapshotChannel
(
	snapshot_id		number
				constraint rhn_snapchan_sid_nn not null
				constraint rhn_snapchan_sid_fk
					references rhnSnapshot(id)
					on delete cascade,
	channel_id		number
				constraint rhn_snapchan_cid_nn not null
				constraint rhn_snapchan_cid_fk
					references rhnChannel(id)
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_snapchan_sid_cid_uq
	on rhnSnapshotChannel( snapshot_id, channel_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
create index rhn_snapshot_cid_idx
	on rhnSnapshotChannel( channel_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_snapchan_mod_trig
before insert or update on rhnSnapshotChannel
for each row
begin
	update rhnSnapshot set modified = sysdate where id = :new.snapshot_id;
end;
/
show errors
				
--
-- $Log$
-- Revision 1.6  2004/01/15 21:25:50  pjones
-- bugzilla: none (Joe is filing one now, maybe?)
-- Fix deletion of snapshots
-- Fix deletion of channels once a snapshot has been taken of a server
--   in said channel
--
-- Revision 1.5  2003/11/09 16:59:10  pjones
-- bugzilla: 109083 -- this doesn't need to be excluded now
--
-- Revision 1.4  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
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
