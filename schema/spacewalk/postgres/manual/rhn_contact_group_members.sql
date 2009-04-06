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
--

--contact_group_members current prod row count = 976
create table 
rhn_contact_group_members
(
	contact_group_id	numeric not null
				constraint rhn_cntgm_cgid_fk
					references rhn_contact_groups(recid)
					on delete cascade,
	order_number		numeric not null,
	member_contact_method_id numeric
				constraint rhn_cntgm_mcmid_fk
					references rhn_contact_methods(recid)
					on delete cascade,
	member_contact_group_id	numeric
				constraint rhn_cntgm_mcgid_fk
					references rhn_contact_groups(recid)
					on delete cascade,
	last_update_user	varchar(40) not null,
	last_update_date	date not null,
				constraint rhn_cntgm_cgid_order_pk primary key ( contact_group_id, order_number )
)  
  ;

comment on table rhn_contact_group_members 
	is 'cntgm  contact group membership records';

-- supports rhn_cntgm_cgid_fk's delete cascade, and also the pk
create index rhn_cntgm_cgid_order_idx 
	on rhn_contact_group_members( contact_group_id, order_number )
--	tablespace [[2m_tbs]]
  ;
-- supports rhn_cntgm_mcmid_fk's delete cascade
create index rhn_cntgm_mcmid_idx
	on rhn_contact_group_members( member_contact_method_id )
--	tablespace [[2m_tbs]]
  ;

-- supports rhn_cntgm_mcgid_fk's delete cascade
create index rhn_cntgm_mcgid_idx
	on rhn_contact_group_members( member_contact_group_id )
--	tablespace [[2m_tbs]]
  ;

--
--
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/05/19 02:16:25  kja
--Fixed syntax issues.
--
--Revision 1.2  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--
--
--
--
