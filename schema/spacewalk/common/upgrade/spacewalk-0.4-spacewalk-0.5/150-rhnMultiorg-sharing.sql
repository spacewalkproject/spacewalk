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
-- Generated from ../common: DO NOT EDIT HERE!
--



ALTER TABLE rhnPackageChangeLog
    DROP CONSTRAINT rhn_pkg_changelog_pid_fk;

ALTER TABLE rhnPackageChangeLog
    ADD CONSTRAINT rhn_pkg_changelog_pid_fk FOREIGN KEY (package_id)
    REFERENCES rhnPackage (id)
        ON DELETE CASCADE;

ALTER TABLE rhnPackageFile
    DROP CONSTRAINT rhn_package_file_pid_fk;

ALTER TABLE rhnPackageFile
    ADD CONSTRAINT rhn_package_file_pid_fk FOREIGN KEY (package_id)
    REFERENCES rhnPackage (id)
        ON DELETE CASCADE;

ALTER TABLE rhnPackageObsoletes
    DROP CONSTRAINT rhn_pkg_obsoletes_package_fk;

ALTER TABLE rhnPackageObsoletes
    ADD CONSTRAINT rhn_pkg_obsoletes_package_fk FOREIGN KEY (package_id)
    REFERENCES rhnPackage (id)
        ON DELETE CASCADE;

ALTER TABLE rhnPackageConflicts
    DROP CONSTRAINT rhn_pkg_conflicts_package_fk;

ALTER TABLE rhnPackageConflicts
    ADD CONSTRAINT rhn_pkg_conflicts_package_fk FOREIGN KEY (package_id)
    REFERENCES rhnPackage (id)
        ON DELETE CASCADE;

ALTER TABLE rhnPackageProvides
    DROP CONSTRAINT rhn_pkg_provides_package_fk;

ALTER TABLE rhnPackageProvides
    ADD CONSTRAINT rhn_pkg_provides_package_fk FOREIGN KEY (package_id)
    REFERENCES rhnPackage (id)
        ON DELETE CASCADE;

ALTER TABLE rhnPackageRequires
    DROP CONSTRAINT rhn_pkg_requires_package_fk;

ALTER TABLE rhnPackageRequires
    ADD CONSTRAINT rhn_pkg_requires_package_fk FOREIGN KEY (package_id)
    REFERENCES rhnPackage (id)
        ON DELETE CASCADE;

ALTER TABLE rhnSystemMigrations
    DROP CONSTRAINT rhn_sys_mig_oidto_fk;

ALTER TABLE rhnSystemMigrations
    ADD CONSTRAINT rhn_sys_mig_oidto_fk FOREIGN KEY (org_id_to)
    REFERENCES web_customer (id)
        ON DELETE SET NULL;

ALTER TABLE rhnSystemMigrations
    DROP CONSTRAINT rhn_sys_mig_oidfrm_fk;

ALTER TABLE rhnSystemMigrations
    ADD CONSTRAINT rhn_sys_mig_oidfrm_fk FOREIGN KEY (org_id_from)
    REFERENCES web_customer (id)
        ON DELETE SET NULL;

