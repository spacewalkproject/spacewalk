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
	id		numeric
			constraint web_contact_pk primary key
--				using index tablespace [[web_index_tablespace_2]]
				,
	org_id		numeric not null
			constraint web_contact_org_fk
				references web_customer(id),
	login	   	varchar(64) not null,
			-- no unique here; it should get caught by login_ucs
	login_uc	varchar(64) not null
			constraint web_contact_login_uc_unq unique
--				using index tablespace [[web_index_tablespace_2]]
				,
	password	varchar(38) not null,
	old_password	varchar(38),
	created		timestamp default(current_timestamp) not null,
	modified	timestamp default(current_timestamp) not null,
	oracle_contact_id numeric
			constraint web_contact_ocid_unq unique
--				using index tablespace [[web_index_tablespace_2]]
				,
	ignore_flag	char(1) default('N') not null
			constraint web_contact_ignore_ck
				check (ignore_flag in ('N','Y'))
)
-- tablespace [[web_tablespace_2]]
;

create sequence web_contact_id_seq;

create index web_contact_oid_id
	on web_contact(org_id, id)
--	tablespace [[web_index_tablespace_2]]
;
	
create index web_contact_id_oid_cust_luc on
	web_contact(id,oracle_contact_id,org_id,login_uc)
--	tablespace [[web_index_tablespace_2]]
  ;

