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

create sequence web_cust_notif_seq start with 1000000;

create table
web_customer_notification
(
	id			numeric not null
				constraint web_cust_not_id_pk primary key,
--					using index tablespace [[64k_tbs]],
	org_id			numeric not null
				constraint web_cust_not_oid_fk
					references web_customer(id)
					on delete cascade,
	contact_email_address	varchar(150) not null,
	creation_date		date not null
)
	 ;

--
--
-- Revision 1.3  2003/10/20 15:07:05  pjones
-- bugzilla: none -- cleanup that has been needed for quite some time
--
