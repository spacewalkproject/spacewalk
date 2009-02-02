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
rhnServerGroupType
(
        id              numeric
                        constraint rhn_servergrouptype_id_pk primary key
--                                using index tablespace [[64k_tbs]]
			,
        label           varchar(32) not null
			constraint rhn_servergrouptype_label_uk unique
--				using index tablespace [[64k_tbs]]
			,
        name            varchar(64) not null,
        created         timestamp default(CURRENT_TIMESTAMP) not null,
        modified        timestamp default(CURRENT_TIMESTAMP) not null,
        permanent       char default('Y') not null,
                        constraint rhn_servergrouptype_perm_ck 
                           check (permanent in ('Y','N'))
        is_base         char default('Y') not null
                        constraint rhn_servergrouptype_isbase_ck
                           check (is_base in ('Y','N'))
)
  ;

create sequence rhn_servergroup_type_seq;

