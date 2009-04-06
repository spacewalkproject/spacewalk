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
rhnUserServerPerms
(
	user_id		numeric
			not null
			constraint rhn_usperms_uid_fk
				references web_contact(id),
	server_id	numeric
			not null
			constraint rhn_usperms_sid_fk
				references rhnServer(id),
                        constraint rhn_usperms_uid_sid_uq 
                        unique( user_id, server_id )
--                        using index tablespace [[8m_tbs]]
)
  ;

create index rhn_usperms_sid_idx
	on rhnUserServerPerms( server_id )
--	tablespace [[4m_tbs]]
  ;

--
--
-- Revision 1.1  2004/07/02 18:57:04  pjones
-- bugzilla: 125937 -- to which servers does a user have permissions.
--
