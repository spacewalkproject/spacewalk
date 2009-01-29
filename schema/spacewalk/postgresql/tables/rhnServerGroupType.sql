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
			constraint rhn_servergrouptype_id_nn not null
                        constraint rhn_servergrouptype_id_pk primary key
--                                using index tablespace [[64k_tbs]]
			,
        label           varchar(32)
                        constraint rhn_servergrouptype_label_nn not null,
        name            varchar(64)
                        constraint rhn_servergrouptype_name_nn not null,
        created         date default(CURRENT_TIMESTAMP)
                        constraint rhn_servergrouptype_created_nn not null,
        modified        date default(CURRENT_TIMESTAMP)
                        constraint rhn_servergrouptype_mod_nn not null,
        permanent       char default('Y')
                        constraint rhn_servergrouptype_perm_ck 
                           check (permanent in ('Y','N'))
                        constraint rhn_servergrouptype_perm_nn not null,
        is_base         char default('Y')
                        constraint rhn_servergrouptype_isbase_ck
                           check (is_base in ('Y','N'))
                        constraint rhn_servergrouptype_isbase_nn not null
)
--	enable row movement
  ;

create sequence rhn_servergroup_type_seq;

create unique index rhn_servergrouptype_label_uq 
	on rhnServerGroupType(label)
--	tablespace [[64k_tbs]]
  ;

--
-- Revision 1.12  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.11  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
