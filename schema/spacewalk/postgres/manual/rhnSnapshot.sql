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

create sequence rhn_snapshot_id_seq;

create table
rhnSnapshot
(
	id			numeric
				not null
				constraint rhn_snapshot_id_pk primary key
--				using index tablespace [[8m_tbs]]
                                ,
	org_id			numeric
				not null
				constraint rhn_snapshot_oid_fk
					references web_customer(id),
	invalid			numeric
				constraint rhn_snapshot_invalid_fk
					references rhnSnapshotInvalidReason(id),
	reason			varchar(4000)
				not null,
	-- We had previously decided that snapshots could exist without a
	-- server associated with them; at this point, that seems to be 
	-- wrong, so it's going to be not null and have an on delete cascade.
	server_id		numeric
				not null
				constraint rhn_snapshot_sid_fk
					references rhnServer(id),
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null
)
 ;

-- need these for delete cascade, but that's basically all they're for
create index rhn_snapshot_sid_idx
	on rhnSnapshot( server_id )
--	tablespace [[2m_tbs]]
        ;

create index rhn_snapshot_oid_idx
	on rhnSnapshot( org_id )
--	tablespace [[2m_tbs]]
        ;

--
--
-- Revision 1.8  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.7  2004/01/15 21:25:50  pjones
-- bugzilla: none (Joe is filing one now, maybe?)
-- Fix deletion of snapshots
-- Fix deletion of channels once a snapshot has been taken of a server
--   in said channel
--
-- Revision 1.6  2003/12/19 15:57:27  pjones
-- bugzilla: none -- remove bad whitespace
--
-- Revision 1.5  2003/10/16 18:09:07  pjones
-- bugzilla: none -- get rid of blank line in the middle
--
-- Revision 1.4  2003/10/09 20:02:26  bretm
-- bugzilla:  106190
--
-- added reason column and support for snapshots
--
-- Revision 1.3  2003/10/07 20:49:18  pjones
-- bugzilla: 106188
--
-- snapshot invalidation
--
-- Revision 1.2  2003/09/17 18:47:10  bretm
-- bugzilla:  103957
--
-- o  do not give a synonym for a table to a sequence
-- o  use the right synonym-creation file
-- o  creating a snapshot shouldn't need a namespace.  namespace implementation details are internal to a snapshot depending on rules yet to be determined.
--
-- Revision 1.1  2003/09/15 21:01:08  pjones
-- bugzilla: none
--
-- tables for snapshot support; still need to write the code to build a snapshot
-- from a working system, but that's pretty simple.
--
