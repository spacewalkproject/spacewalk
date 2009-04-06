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


CREATE TABLE rhnServerPackageArchCompat
(
    server_arch_id   NUMBER NOT NULL 
                         CONSTRAINT rhn_sp_ac_said_fk
                             REFERENCES rhnServerArch (id), 
    package_arch_id  NUMBER NOT NULL 
                         CONSTRAINT rhn_sp_ac_paid_fk
                             REFERENCES rhnPackageArch (id), 
    preference       NUMBER NOT NULL, 
    created          DATE 
                         DEFAULT (sysdate) NOT NULL, 
    modified         DATE 
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_sp_ac_said_paid_pref
    ON rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_sp_ac_paid_said_pref
    ON rhnServerPackageArchCompat (package_arch_id, server_arch_id, preference)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhnServerPackageArchCompat
    ADD CONSTRAINT rhn_sp_ac_said_paid_uq UNIQUE (server_arch_id, package_arch_id);

ALTER TABLE rhnServerPackageArchCompat
    ADD CONSTRAINT rhn_sp_ac_pref_said_uq UNIQUE (preference, server_arch_id) 
    USING INDEX TABLESPACE [[64k_tbs]];

