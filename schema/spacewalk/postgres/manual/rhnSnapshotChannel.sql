--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

create table
rhnSnapshotChannel
(
	snapshot_id		numeric
				not null
				constraint rhn_snapchan_sid_fk
					references rhnSnapshot(id)
					on delete cascade,
	channel_id		numeric
				not null
				constraint rhn_snapchan_cid_fk
					references rhnChannel(id),
                                constraint rhn_snapchan_sid_cid_uq
                                unique( snapshot_id, channel_id )
--                              using index tablespace [[8m_tbs]]
)
 ;

create index rhn_snapshot_cid_idx
	on rhnSnapshotChannel( channel_id )
--	tablespace [[4m_tbs]]
        ;
/*
create or replace trigger
rhn_snapchan_mod_trig
before insert or update on rhnSnapshotChannel
for each row
begin
	update rhnSnapshot set modified = sysdate where id = :new.snapshot_id;
end;
/
show errors
*/				
--
--
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
