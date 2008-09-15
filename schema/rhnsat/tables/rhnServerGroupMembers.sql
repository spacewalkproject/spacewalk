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
rhnServerGroupMembers
(
        server_id       number
                        constraint rhn_sg_members_nn not null
                        constraint rhn_sg_members_fk
                                references rhnServer(id),
        server_group_id number
                        constraint rhn_sg_group_nn not null
                        constraint rhn_sg_groups_fk
                                references rhnServerGroup(id),
        created         date default(sysdate)
                        constraint rhn_sg_member_cre_nn not null,
        modified        date default(sysdate)
                        constraint rhn_sg_member_mod_nn not null
)
	storage( pctincrease 1 freelists 16 )
	enable row movement
	initrans 32;

-- $Log$
-- Revision 1.11  2004/01/15 15:58:48  pjones
-- bugzilla: 113566 -- make delete_server() remove from servergroups correctly.
--
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
