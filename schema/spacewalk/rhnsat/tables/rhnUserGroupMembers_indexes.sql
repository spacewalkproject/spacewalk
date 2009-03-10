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

create unique index rhn_ugmembers_uid_ugid_uq
	on rhnUserGroupMembers(user_id, user_group_id)
	tablespace [[8m_tbs]]
  ;

create index rhn_ugmembers_ugid_uid_idx
	on rhnUserGroupMembers(user_group_id, user_id)
	tablespace [[8m_tbs]]
	nologging;


--
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
