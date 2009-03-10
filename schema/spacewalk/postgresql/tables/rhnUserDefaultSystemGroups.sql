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

create table
rhnUserDefaultSystemGroups
(
	user_id		numeric
			not null
			constraint rhn_udsg_uid_fk
				references web_contact(id)
				on delete cascade,
	system_group_id	numeric
			not null
			constraint rhn_udsg_cidffk
				references rhnServerGroup(id)
				on delete cascade,
                        constraint rhn_udsg_uid_sgid_idx
                        unique(user_id, system_group_id)
--                        using index tablespace [[2m_tbs]]
)
 ;

create index rhn_udsg_sgid_uid_idx
	on rhnUserDefaultSystemGroups(system_group_id, user_id)
--	tablespace [[2m_tbs]]
  ;
