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
web_contact
(
	id		number
			constraint web_contact_pk primary key
				using index tablespace [[web_index_tablespace_2]]
				storage(pctincrease 1),
	org_id		number
			constraint web_contact_org_nn not null
			constraint web_contact_org_fk
				references web_customer(id),
	login	   	varchar2(64)
			constraint web_contact_login_nn not null,
			-- no unique here; it should get caught by login_ucs
	login_uc	varchar2(64)
			constraint web_contact_login_uc_nn not null
			constraint web_contact_login_uc_unq unique
				using index tablespace [[web_index_tablespace_2]]
				storage(pctincrease 1),
	password	varchar2(38)
			constraint web_contact_password_nn not null,
	old_password	varchar2(38),
	created		date default(sysdate)
			constraint web_contact_created_nn not null,
	modified	date default(sysdate)
			constraint web_contact_modified_nn not null,
	oracle_contact_id number
			constraint web_contact_ocid_unq unique
				using index tablespace [[web_index_tablespace_2]]
				storage(pctincrease 1),
	ignore_flag	char(1) default('N')
			constraint web_contact_ignore_nn not null
			constraint web_contact_ignore_ck
				check (ignore_flag in ('N','Y'))
)
tablespace [[web_tablespace_2]]
storage(pctincrease 1)
enable row movement
;

create sequence web_contact_id_seq;

-- $Log$
-- Revision 1.15  2002/06/11 15:13:53  cturner
-- 38, not 36, "just in case"
--
-- Revision 1.14  2002/06/11 02:38:22  cturner
-- 36, not 32, shall be the password length
--
-- Revision 1.13  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.12  2002/05/09 01:57:04  gafton
-- typo
--
-- Revision 1.11  2002/05/08 19:05:22  pjones
-- more consolidation
--
-- Revision 1.10  2002/05/08 18:26:41  pjones
-- more unification
--
-- Revision 1.9  2002/05/08 18:08:05  pjones
-- unify satellite and live
--
