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
-- This specifies the list of transaction packages for a given delta
-- It's just like rhnTransactionElement, except it's for rhnPackageDelta entries
-- instead.
--
-- Note that this only really exists because we want labels, and so 
-- we need something between rhnActionPackageDelta and rhnTransactionPackage .

create table
rhnPackageDeltaElement
(
	package_delta_id	numeric
				not null
				constraint rhn_pdelement_pdid_fk
				references rhnPackageDelta(id)
				on delete cascade,
	transaction_package_id	numeric
				not null
				constraint rhn_pdelement_tpid_fk
				references rhnTransactionPackage(id),
                                constraint rhn_pdelement_pdid_tpid_uq
                                unique(package_delta_id, transaction_package_id)
--                              using index tablespace [[8m_tbs]]
)
  ;

--
-- Revision 1.1  2003/06/10 19:42:25  pjones
-- package delta actions
--

