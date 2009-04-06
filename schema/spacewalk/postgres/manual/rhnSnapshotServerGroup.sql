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
rhnSnapshotServerGroup
(
	snapshot_id		numeric
				not null
				constraint rhn_snapshotsg_sid_fk
					references rhnSnapshot(id)
					on delete cascade,
	server_group_id		numeric
				not null
				constraint rhn_snapshotsg_sgid_fk
			        references rhnServerGroup(id),
                                constraint rhn_snapshotsg_sid_sgid_uq
                                unique( snapshot_id, server_group_id )
--                              using index tablespace [[4m_tbs]]
)
  ;

create index rhn_snapshotsg_sgid_idx
	on rhnSnapshotServerGroup( server_group_id )
--	tablespace [[2m_tbs]]
  ;

/*
create or replace trigger
rhn_snapshotsg_mod_trig
before insert or update on rhnSnapshotServerGroup
for each row
begin
	update rhnSnapshot set modified = sysdate where id = :new.snapshot_id;
end;
/
show errors
*/				
--
--
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
