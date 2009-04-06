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
-- This holds log information about email addresses

create table
rhnEmailAddressLog
(
	user_id			numeric
				not null
				constraint rhn_eaddresslog_uid_fk
				references web_contact(id)
				on delete cascade,
	address			varchar(128)
				not null,
	reason			varchar(4000),
	created			date default(current_date)
				not null
)
--	tablespace [[8m_data_tbs]]
  ;

create index rhn_eaddresslog_uid_idx
	on rhnEmailAddressLog(user_id)
--	tablespace [[4m_tbs]]
  ;
create index rhn_eaddresslog_a_idx
	on rhnEmailAddressLog(address)
--	tablespace [[4m_tbs]]
  ;
create index rhn_eaddresslog_created_idx
	on rhnEmailAddressLog(created)
--	tablespace [[4m_tbs]]
  ;

--
-- Revision 1.7  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.6  2003/02/03 16:33:00  pjones
-- tablespace changes
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2003/01/30 15:19:07  cturner
-- add user_id column to replace removed address_id column
--
-- Revision 1.3  2003/01/29 00:41:37  cturner
-- just address, no need for FK to rhnEmailAddress
--
-- Revision 1.2  2003/01/29 00:02:02  pjones
-- add address column
--
-- Revision 1.1  2003/01/28 22:48:52  pjones
-- logging for rhnEmailAddress and rhnOrgState
--
