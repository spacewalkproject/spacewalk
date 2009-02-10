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
rhnSnapshotConfigRevision
(
	snapshot_id		numeric
				not null
				constraint rhn_snapshotcr_sid_fk
					references rhnSnapshot(id)
					on delete cascade,
	config_revision_id	numeric
				not null
				constraint rhn_snapshotcr_crid_fk
					references rhnConfigRevision(id),
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_snapshotcr_sid_crid_uq 
                                unique( snapshot_id, config_revision_id )
--                              using index tablespace [[2m_tbs]]
)
  ;

create index rhn_sscr_crid_sid_idx
on rhnSnapshotConfigRevision ( config_revision_id, snapshot_id )
--        tablespace [[2m_tbs]]
  ;
/*
create or replace trigger
rhn_snapshotcr_mod_trig
before insert or update on rhnSnapshotConfigRevision
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.3  2004/01/15 21:25:50  pjones
-- bugzilla: none (Joe is filing one now, maybe?)
-- Fix deletion of snapshots
-- Fix deletion of channels once a snapshot has been taken of a server
--   in said channel
--
-- Revision 1.2  2003/11/14 21:00:44  pjones
-- bugzilla: none -- snapshot invalid on config rev removal
--
-- Revision 1.1  2003/11/09 17:01:05  pjones
-- bugzilla: 109083 -- a snapshot contains a revision of a file which gets
-- deployed
--
