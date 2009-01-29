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
rhnUserGroup
(
        id              numeric
                        constraint rhn_user_group_id_nn not null
                        constraint rhn_user_group_pk primary key
--                                using index tablespace [[8m_tbs]]
				,
        name            varchar(64)
                        constraint rhn_user_group_name_nn not null,
        description     varchar(1024)
                        constraint rhn_user_group_desc_nn not null,
        max_members     numeric,
        current_members numeric default(0)
                        constraint rhn_user_group_cm_nn not null,
        group_type      numeric
                        constraint rhn_usergroup_type_nn not null
                        constraint rhn_usergroup_type_fk
                                references rhnUserGroupType(id),
        org_id          numeric
                        constraint rhn_user_group_org_id_nn not null
                        constraint rhn_user_group_org_fk
                                references web_customer(id)
				on delete cascade,
        created         date default(CURRENT_TIMESTAMP)
                        constraint rhn_usergroup_type_created_nn not null,
        modified        date default(CURRENT_TIMESTAMP)
                        constraint rhn_usergroup_type_modified_nn not null
)
--	enable row movement
  ;

--
-- Revision 1.19  2003/03/14 23:15:14  pjones
-- org deletion
--
-- Revision 1.18  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.17  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
