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
-- $Id$
--

create table
rhnUserServerGroupPerms
(
        user_id         number
                        constraint rhn_usgp_user_nn not null
                        constraint rhn_usgp_user_fk
                                references web_contact(id) on delete cascade,
        server_group_id number
                        constraint rhn_usgp_server_nn not null
                        constraint rhn_usgp_server_fk
                                references rhnServerGroup(id) on delete cascade,
        created         date default(sysdate)
                        constraint rhn_usgp_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_usgp_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create UNIQUE index rhn_usgp_u_sg_p_uq
	on rhnUserServerGroupPerms(user_id, server_group_id)
        tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
create index rhn_usgp_sg_u_p_idx
        on rhnUserServerGroupPerms(server_group_id, user_id)
        tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/05/10 22:00:49  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
