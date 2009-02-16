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
        id              numeric
                        constraint rhn_servergroup_id_pk primary key
--                      using index tablespace [[4m_tbs]]
			,
        name            varchar(64)
                        not null,
        description     varchar(1024)
                        not null,
        max_members     numeric,
	current_members numeric default 0
                        not null,
        group_type      numeric
                        constraint rhn_servergroup_type_fk
                        references rhnServerGroupType(id),
        org_id          numeric
                        not null
                        constraint rhn_servergroup_oid_fk
                        references web_customer(id)
			on delete cascade,
        created         date default(current_date)
                        not null,
        modified        date default(current_date)
                        not null,
                        constraint rhn_servergroup_oid_name_uq
                        unique(org_id, name)
--                      using index tablespace [[4m_tbs]]
)
  ;

create sequence rhn_server_group_id_seq;

create index rhn_sg_id_oid_name_idx
        on rhnServerGroup(id,org_id,name)
--      tablespace [[4m_tbs]]
        ;

create index rhn_sg_oid_id_name_idx
        on rhnServerGroup(org_id,id,name)
--      tablespace [[8m_tbs]]
        ;

create index rhn_sg_type_id_idx
        on rhnServerGroup(group_type,id)
--        tablespace [[4m_tbs]]
        ;

create index rhn_sg_oid_type_id_idx
        on rhnServerGroup(org_id, group_type, id)
--      tablespace [[4m_tbs]]
        ;


--
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
