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
-- a package that's in a transaction element.

create table
rhnTransactionPackage
(
	id		numeric
			constraint rhn_transpack_id_pk primary key
--      		using index tablespace [[8m_tbs]],
                        ,
	operation	numeric
			not null
			constraint rhn_transpack_op_fk
				references rhnTransactionOperation(id),
	name_id		numeric
			not null
			constraint rhn_transpack_nid_fk
				references rhnPackageName(id),
	evr_id		numeric
			not null
			constraint rhn_transpack_eid_fk
				references rhnPackageEVR(id),
	package_arch_id	numeric
			constraint rhn_transpack_paid_fk
			references rhnPackageArch(id),
                        constraint rhn_transpack_onea_uq 
                        unique(operation, name_id, evr_id, package_arch_id)
--                      using index tablespace [[8m_tbs]]
)
  ;

create sequence rhn_transpack_id_seq;

--
-- Revision 1.7  2003/07/02 19:57:31  pjones
-- bugzilla: none -- arch is not required
--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/11/14 17:31:37  pjones
-- more arch changes -- remove the old fields
--
-- Revision 1.4  2002/11/13 22:45:20  pjones
-- add appropriate arch fields.
-- haven't deleted the old ones yet though
--
-- Revision 1.3  2002/09/27 15:16:34  misa
-- Typo
--
-- Revision 1.2  2002/09/26 14:37:18  pjones
-- add sequence for rhnTransactionPackage.id
--
-- Revision 1.1  2002/09/26 14:35:44  pjones
-- seperate out package from the element, so that it's not related a
-- user/transaction.
--

