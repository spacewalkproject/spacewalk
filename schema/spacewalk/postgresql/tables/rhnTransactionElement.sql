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
-- Our idea of an RPM transaction element
--
-- Jeff tells me these aren't ordered, so no need for position.

create table
rhnTransactionElement
(
	transaction_id		numeric
				not null
				constraint rhn_transelem_tid_fk
					references rhnTransaction(id)
					on delete cascade,
	transaction_package_id	numeric
				not null
				constraint rhn_transelem_tpid_fk
					references rhnTransactionPackage(id),
                                constraint rhn_transelem_tid_tpid_uq 
                                unique(transaction_id,transaction_package_id)
--                                using index tablespace [[8m_tbs]]
)
  ;


--
-- Revision 1.4  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.3  2002/09/26 14:35:44  pjones
-- seperate out package from the element, so that it's not related a
-- user/transaction.
--
-- Revision 1.2  2002/09/25 19:09:02  pjones
-- transaction changes discussed today
--
-- Revision 1.1  2002/09/04 20:30:16  pjones
-- schema for transactions
--
