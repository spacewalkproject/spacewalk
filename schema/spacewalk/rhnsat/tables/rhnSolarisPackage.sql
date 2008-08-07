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
create table rhnSolarisPackage (
   package_id              number
                           constraint rhn_solaris_pkg_pid_pk primary key
                           constraint rhn_solaris_pkg_pid_fk references rhnPackage(id)
                           on delete cascade,
   category                varchar2(2048)
                           constraint rhn_solaris_pkg_cat_nn not null,
   pkginfo                 varchar2(4000),
   pkgmap                  blob,
   intonly                 char(1) default 'N'
                           constraint rhn_solaris_pkg_io_ck check ( intonly in ('Y','N'))
)
	tablespace [[8m_data_tbs]]
	storage( pctincrease 1 freelists 16 )
	enable row movement
	initrans 32;





--
-- $Log$
--
