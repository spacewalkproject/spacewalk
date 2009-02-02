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
--                                using index tablespace [[4m_tbs]]
			,
        name            varchar(64) not null,
        description     varchar(1024) not null,
        max_members     numeric,
	current_members numeric default 0 not null,
        group_type      numeric
                        constraint rhn_servergroup_type_fk
                                references rhnServerGroupType(id),
        org_id          numeric not null
                        constraint rhn_servergroup_oid_fk
                                references web_customer(id)
				on delete cascade,
        created         timestamp default(CURRENT_TIMESTAMP) not null,
        modified        timestamp default(CURRENT_TIMESTAMP) not null
)
  ;

create sequence rhn_server_group_id_seq;

create unique index rhn_servergroup_oid_name_uq
       on rhnServerGroup(org_id, name)
--     tablespace [[4m_tbs]]

