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
-- $Id$
--

create sequence rhn_pkgnevra_id_seq;

create table
rhnPackageNEVRA
(
	id			number
				constraint rhn_pkgnevra_id_nn not null
				constraint rhn_pkgnevra_id_pk primary key
					using index tablespace [[8m_tbs]],
	name_id			number
				constraint rhn_pkgnevra_nid_nn not null
				constraint rhn_pkgnevra_nid_fk
					references rhnPackageName(id),
	evr_id			number
				constraint rhn_pkgnevra_eid_nn not null
				constraint rhn_pkgnevra_eid_fk
					references rhnPackageEVR(id),
	-- we don't have the data for arch just yet, in reality,
	-- so leave it nullable.  someday...
	package_arch_id		number
				constraint rhn_pkgnevra_paid_fk
					references rhnPackageArch(id)
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_pkgnevra_nid_evrid_id_idx
	on rhnPackageNEVRA( name_id, evr_id, id )
	tablespace [[32m_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhnPackageNEVRA
add constraint rhn_pkgnevra_nid_eid_paid_uq
unique ( name_id, evr_id, package_arch_id );

--
-- $Log$
-- Revision 1.1  2003/09/15 21:01:08  pjones
-- bugzilla: none
--
-- tables for snapshot support; still need to write the code to build a snapshot
-- from a working system, but that's pretty simple.
--
