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
db_change_resource_names
(
	resource_type	varchar2(255)
			constraint dc_resourcename_rt_nn not null
			constraint dc_resourcename_rt_fk
				references db_change_resource_types(resource_type),
	resource_name	varchar2(255)
			constraint dc_resourcename_rn_nn not null
)
	storage ( freelists 16 )
	initrans 32;

COMMENT ON TABLE db_change_resource_names IS
	'DBCRN  Resources that can be changed (e.g. table WEB_USER)';

create index dc_resourcename_rt_rn_idx
	on db_change_resource_names( resource_type, resource_name )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_resource_names add constraint dc_resourcename_rt_rn_pk
	primary key ( resource_type, resource_name );

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
