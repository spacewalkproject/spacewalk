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
ALTER TABLE rhnPackageChangeLog
  DROP constraint rhn_pkg_changelog_pid_fk;

ALTER TABLE rhnPackageChangeLog
  ADD constraint rhn_pkg_changelog_pid_fk
    foreign key (package_id)
    references rhnPackage (id)
    on delete cascade;

ALTER TABLE rhnPackageFile
  DROP constraint rhn_package_file_pid_fk;

ALTER TABLE rhnPackageFile
  ADD constraint rhn_package_file_pid_fk
    foreign key (package_id)
    references rhnPackage (id)
    on delete cascade;

ALTER TABLE rhnPackageObsoletes
  DROP constraint rhn_pkg_obsoletes_package_fk;

ALTER TABLE rhnPackageObsoletes
  ADD constraint rhn_pkg_obsoletes_package_fk
    foreign key (package_id)
    references rhnPackage (id)
    on delete cascade;

ALTER TABLE rhnPackageConflicts
  DROP constraint rhn_pkg_conflicts_package_fk;

ALTER TABLE rhnPackageConflicts
  ADD constraint rhn_pkg_conflicts_package_fk
    foreign key (package_id)
    references rhnPackage (id)
    on delete cascade;

ALTER TABLE rhnPackageProvides
  DROP constraint rhn_pkg_provides_package_fk;

ALTER TABLE rhnPackageProvides
  ADD constraint rhn_pkg_provides_package_fk
    foreign key (package_id)
    references rhnPackage (id)
    on delete cascade;

ALTER TABLE rhnPackageRequires
  DROP constraint rhn_pkg_requires_package_fk;

ALTER TABLE rhnPackageRequires
  ADD constraint rhn_pkg_requires_package_fk
    foreign key (package_id)
    references rhnPackage (id)
    on delete cascade;

ALTER TABLE rhnSystemMigrations
  DROP constraint rhn_sys_mig_oidto_fk;

ALTER TABLE rhnSystemMigrations
  ADD constraint rhn_sys_mig_oidto_fk
    foreign key (org_id_to)
    references web_customer (id)
    on delete set null;

ALTER TABLE rhnSystemMigrations
  DROP constraint rhn_sys_mig_oidfrm_fk;

ALTER TABLE rhnSystemMigrations
  ADD constraint rhn_sys_mig_oidfrm_fk
    foreign key (org_id_from)
    references web_customer (id)
    on delete set null;
