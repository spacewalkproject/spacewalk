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
web_customer
(
	id		numeric not null
			constraint web_customer_id_pk primary key
--				using index tablespace [[web_index_tablespace_2]]
				,
	name		varchar(128) not null
			constraint web_customer_name_uq_idx unique
--				using index tablespace [[web_tablespace_2]]
			,
	oracle_customer_id numeric
			constraint web_customer_ocid_unq unique
--				using index tablespace [[web_index_tablespace_2]]
				,
	oracle_customer_number numeric
			constraint web_customer_ocn_unq unique
--				using index tablespace [[web_index_tablespace_2]]
				,
	customer_type	char(1) default ('P') not null
			constraint web_customer_type_list
				check (customer_type in ('B', 'P')),
        credit_application_completed char(1),
	created		timestamp default(CURRENT_TIMESTAMP) not null,
	modified	timestamp default(CURRENT_TIMESTAMP) not null
)
-- tablespace [[web_tablespace_2]]
	;

create sequence web_customer_id_seq start with 2;

