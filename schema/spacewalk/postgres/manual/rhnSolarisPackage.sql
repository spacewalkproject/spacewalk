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
create table rhnSolarisPackage (
   package_id              numeric
                           constraint rhn_solaris_pkg_pid_pk primary key
                           constraint rhn_solaris_pkg_pid_fk references rhnPackage(id)
                           on delete cascade,
   category                varchar(2048)
                           not null,
   pkginfo                 varchar(4000),
   pkgmap                  bytea,
   intonly                 char(1) default 'N'
                           constraint rhn_solaris_pkg_io_ck check ( intonly in ('Y','N'))
)
--	tablespace [[8m_data_tbs]]
  ;





--
--
--
