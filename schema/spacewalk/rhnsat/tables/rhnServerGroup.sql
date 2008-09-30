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
rhnServerGroup
(
        id              number
                        constraint rhn_servergroup_id_nn not null
                        constraint rhn_servergroup_id_pk primary key
                                using index tablespace [[4m_tbs]]
				storage(pctincrease 1),
        name            varchar2(64)
                        constraint rhn_servergroup_name_nn not null,
        description     varchar2(1024)
                        constraint rhn_servergroup_desc_nn not null,
        max_members     number,
	current_members number default 0
                        constraint rhn_servergroup_curmembers_nn not null,
        group_type      number
                        constraint rhn_servergroup_type_fk
                                references rhnServerGroupType(id),
        org_id          number
                        constraint rhn_servergroup_oid_nn not null
                        constraint rhn_servergroup_oid_fk
                                references web_customer(id)
				on delete cascade,
        created         date default(sysdate)
                        constraint rhn_servergroup_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_servergroup_modified_nn not null
)
	storage( pctincrease 1 freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_server_group_id_seq;

create unique index rhn_servergroup_oid_name_uq
	on rhnServerGroup(org_id, name)
	tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.17  2003/03/14 23:24:17  pjones
-- org deletion
--
-- Revision 1.16  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.15  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
