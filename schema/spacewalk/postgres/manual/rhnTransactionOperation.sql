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
-- Our idea of an RPM transaction element's operation

create table
rhnTransactionOperation
(
	id		numeric
			not null
			constraint rhn_transop_id_pk primary key
--           		using index tablespace [[8m_tbs]]
                        ,
	label		varchar(32)
			not null
			constraint rhn_transop_label_uq unique
--			using index tablespace [[8m_tbs]]
                        ,
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null
)
  ;

create index rhn_transop_label_id_idx
	on rhnTransactionOperation(label,id)
--	tablespace [[64k_tbs]]
  ;

--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/09/25 19:09:02  pjones
-- transaction changes discussed today
--
