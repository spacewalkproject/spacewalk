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
-- indices and pk/uq constraints for rhnEmailAddress

-- verification needs an ID based index... what do other things need?
-- basicly, this should only be hit on the "update" path, which has to do
-- a row lookup anyway
create index rhn_eaddress_id_idx
	on rhnEmailAddress ( id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnEmailAddress add
	constraint rhn_eaddress_id_pk primary key ( id );

-- this gets a much higher hitrate with erratamail
create index rhn_eaddress_uid_sid_addr_idx
	on rhnEmailAddress ( user_id, state_id, address )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnEmailAddress add
	constraint rhn_eaddress_uid_sid_uq unique ( user_id, state_id );

-- ugh.  Name too long the sane way, shortened to fit.
create index rhn_eaddress_niusa_idx
	on rhnEmailAddress ( next_action, id, user_id, state_id, address )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
-- Revision 1.7  2003/04/29 15:20:46  pjones
-- another index change that's in the erratamail change file, but that I
-- missed on my commit
--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2003/01/23 17:01:14  pjones
-- put this in the right tablespace
--
-- Revision 1.4  2003/01/22 18:48:37  cturner
-- rename column, add intermediary email step
--
-- Revision 1.3  2003/01/21 16:41:46  pjones
-- redid indexing.  Basicly, selects based on next_attempt don't hit the table,
-- but updates (where the lookup is on id) do a rowid lookup.  user_id will
-- do a rowid lookup as well, but that isn't (yet) the most heavily hit path.
-- If we need to add speed to the uid or id lookups, lemme know.
--
-- Revision 1.2  2003/01/10 22:17:10  pjones
-- add a single-column index on state id
--
-- Revision 1.1  2003/01/10 20:00:18  pjones
-- move indexes and uq/pk out of rhnEmailAddress
-- revamp population script
--
