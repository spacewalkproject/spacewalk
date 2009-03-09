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

create index rhn_sg_id_oid_name_idx
	on rhnServerGroup(id,org_id,name)
        tablespace [[4m_tbs]]
	nologging;
	
create index rhn_sg_oid_id_name_idx
	on rhnServerGroup(org_id,id,name)
        tablespace [[8m_tbs]]
	nologging;
	
create index rhn_sg_type_id_idx
	on rhnServerGroup(group_type,id)
        tablespace [[4m_tbs]]
	nologging;
	
create index rhn_sg_oid_type_id_idx
	on rhnServerGroup(org_id, group_type, id)
        tablespace [[4m_tbs]]
	nologging;

--
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
