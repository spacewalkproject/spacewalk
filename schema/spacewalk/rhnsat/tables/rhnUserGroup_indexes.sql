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
-- Indexes for the rhnUserGroup table
-- they are kept separate to speed up the data import
--

create unique index rhn_ug_oid_name_uq
	on rhnUserGroup(org_id, name)
	tablespace [[32m_tbs]]
  ;

create index rhn_ug_id_name_org
	on rhnUserGroup(id, name, org_id)
	tablespace [[32m_tbs]]
	nologging;
	
create index rhn_ug_org_id_name_idx
	on rhnUserGroup(org_id, id, name)
	tablespace [[32m_tbs]]
	nologging;
	
create index rhn_ug_org_id_type_idx
	on rhnUserGroup(group_type, id)
	tablespace [[8m_tbs]]
	nologging;
	
create index rhn_ug_org_id_gtype_idx
	on rhnUserGroup(org_id, group_type, id)
	tablespace [[8m_tbs]]
  ;
alter table rhnUserGroup add constraint rhn_ug_oid_gt_uq
	unique ( org_id, group_type );

--
-- Revision 1.12  2004/08/10 16:37:03  pjones
-- bugzilla: 128737 -- user group indices to make [org_id,group_type] unique.
--
-- Revision 1.11  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.10  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.9  2002/03/19 22:41:32  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.8  2002/02/21 16:27:20  pjones
-- rhn_ind -> [[8m_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.7  2001/07/25 06:13:43  pjones
-- rename index and put it in the indexes file
--
-- Revision 1.6  2001/07/24 22:17:00  cturner
-- nologging on a bunch of indexes... fun
--
-- Revision 1.5  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.4  2001/07/01 02:36:40  gafton
-- add indexes back here
--
