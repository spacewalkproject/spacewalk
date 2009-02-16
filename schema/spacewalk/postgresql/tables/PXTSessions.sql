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

create table PXTSessions (
        id              numeric
			constraint pxt_sessions_pk primary key,
        web_user_id     numeric
                        constraint pxtsessions_user
	                        references web_contact(id) on delete cascade,
        expires         numeric default 0 not null,
        value           varchar(4000) not null
)
;


create sequence pxt_id_seq;

create index PXTSessions_user
	on PXTSessions(web_user_id) 
--	tablespace [[4m_tbs]]
	;

create index PXTSessions_expires
	on PXTSessions(expires)
--	tablespace [[8m_tbs]]
	;

--
-- Revision 1.12  2003/10/13 14:14:52  pjones
-- bugzilla: none
-- make this table's storage parameters look like all the others; for some
-- reason the current settings blow up bad sometimes.
--
-- Revision 1.11  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.10  2002/12/23 21:39:06  misa
-- Fixing typo
--
-- Revision 1.9  2002/12/03 21:11:57  pjones
-- match don's new INITTRANS/STORAGE changes
--
-- Revision 1.8  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
