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

-- this matches errata <-> packages, many to many.
create table
rhnErrataPackage
(
	errata_id	number
			constraint rhn_err_pkg_eid_nn not null
			constraint rhn_err_pkg_eid_fk
				references rhnErrata(id)
				on delete cascade,
	package_id	number
			constraint rhn_err_pkg_pid_nn not null
			constraint rhn_err_pkg_pid_fk
				references rhnPackage(id)
				on delete cascade,
	created		date default (sysdate)
			constraint rhn_err_pkg_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_err_pkg_modified_nn not null
)
	enable row movement
  ;

create unique index rhn_err_pkg_eid_pid_uq
	on rhnErrataPackage(errata_id, package_id)
	tablespace [[64k_tbs]]
  ;

create index rhn_err_pkg_pid_eid_idx
	on rhnErrataPackage(package_id, errata_id)
	tablespace [[64k_tbs]]
	nologging; 

--
-- Revision 1.16  2003/08/14 19:59:07  pjones
-- bugzilla: none
--
-- reformat "on delete cascade" on things that reference rhnErrata*
--
-- Revision 1.15  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.14  2002/05/09 05:00:23  gafton
-- cascade foreign keys for this relational table
--
-- Revision 1.13  2002/04/10 19:56:25  pjones
-- move triggers out of rhnErrataPackage.sql
--
-- Revision 1.12  2002/04/09 20:04:22  pjones
-- make rhnChannelErrata accurate with triggers instead of just occasionally
-- getting it right.  Also should support delete of packages/channels/errata
-- now
--
-- Revision 1.11  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.10  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.9  2001/07/24 22:17:00  cturner
-- nologging on a bunch of indexes... fun
--
-- Revision 1.8  2001/07/05 20:04:48  pjones
-- make rhn and rhn2 match
-- pick sane constraint names
-- format
--
-- Revision 1.7  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.6  2001/07/01 17:40:22  cturner
-- renaming rhn*PackageObj to rhn*Package.  more work on conversions.
--
-- Revision 1.5  2001/07/01 06:24:18  gafton
-- shorter constraint names
--
-- Revision 1.4  2001/07/01 06:16:56  gafton
-- named constraints, dammit.
--
-- Revision 1.3  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.2  2001/06/27 02:18:12  pjones
-- triggers
--
-- Revision 1.1  2001/06/27 01:46:05  pjones
-- initial checkin

