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
-- this table holds saved searches.

create table
rhnSavedSearch
(
	id		numeric
			constraint rhn_savedsearch_id_pk primary key,
	web_contact_id	numeric
			not null
			constraint rhn_savedsearch_wcid_fk
			references web_contact(id)
			on delete cascade,
	name		varchar(16)
			not null,
	type		numeric
			not null
			constraint rhn_savedsearch_type_fk
			references rhnSavedSearchType(id),
	search_string	varchar(4000)
			not null,
	search_set	varchar(16)
			not null
			constraint rhn_savedsearch_sset_ck
			check ( search_set in ('all','system_list')),
	search_field	varchar(128)
			not null,
	invert		char default('N')
			not null
			constraint rhn_savedsearch_invert_ck
			check (invert in ('Y','N')),
                        constraint rhn_savedsearch_name_wcid_uq 
                        unique (name, web_contact_id)
)
  ;

create sequence rhn_savedsearch_id_seq;

create index rhn_savedsearch_id_wcid_idx
	on rhnSavedSearch(id, web_contact_id)
--	tablespace [[2m_tbs]]
        ;
create index rhn_savedsearch_wcid_id_idx
	on rhnSavedSearch(web_contact_id, id)
--	tablespace [[2m_tbs]]
        ;

create index rhn_savedsearch_name_wcid_idx
	on rhnSavedSearch(name, web_contact_id)
--	tablespace [[2m_tbs]]
        ;

--
-- Revision 1.3  2003/04/02 17:00:04  pjones
-- bugzilla: none
--
-- fix some spots we missed on user del path.
--
-- To find these, do
--
-- select table_name, constraint_name, delete_rule from all_constraints
-- where r_constraint_name = 'WEB_CONTACT_PK'
--         and delete_rule not in ('CASCADE','SET NULL')
--
-- Note that right now in webqa and web there's a "WEB_UBERBLOB" table that's
-- not got the constraints that live does.  how quaint.
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/11/15 20:51:26  pjones
-- add saved search schema
--
