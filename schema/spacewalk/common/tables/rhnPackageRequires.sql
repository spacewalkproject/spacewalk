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


CREATE TABLE rhnPackageRequires
(
    package_id     NUMBER NOT NULL
                       CONSTRAINT rhn_pkg_requires_package_fk
                           REFERENCES rhnPackage (id)
                           ON DELETE CASCADE,
    capability_id  NUMBER NOT NULL
                       CONSTRAINT rhn_pkg_requires_capability_fk
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

CREATE UNIQUE INDEX rhn_pkg_req_pid_cid_s_uq
    ON rhnPackageRequires (package_id, capability_id, sense)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_pkg_requires_cid_idx
    ON rhnPackageRequires (capability_id)
    NOLOGGING
    TABLESPACE [[4m_tbs]];

