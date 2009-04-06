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


CREATE TABLE rhnPackageProvides
(
    package_id     NUMBER NOT NULL 
                       CONSTRAINT rhn_pkg_provides_package_fk
                           REFERENCES rhnPackage (id) 
                           ON DELETE CASCADE, 
    capability_id  NUMBER NOT NULL 
                       CONSTRAINT rhn_pkg_provides_capability_fk
                           REFERENCES rhnPackageCapability (id), 
    sense          NUMBER 
                       DEFAULT (0) NOT NULL, 
    created        DATE 
                       DEFAULT (sysdate) NOT NULL, 
    modified       DATE 
                       DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_pkg_prov_cid_pid_s_uq
    ON rhnPackageProvides (capability_id, package_id, sense)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_pkg_provides_pid_idx
    ON rhnPackageProvides (package_id)
    LOGGING
    TABLESPACE [[2m_tbs]];

