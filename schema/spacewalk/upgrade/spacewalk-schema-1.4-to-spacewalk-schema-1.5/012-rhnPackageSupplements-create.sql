--
-- Copyright (c) 2010 Novell
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
--


CREATE TABLE rhnPackageSupplements
(
    package_id     NUMBER NOT NULL
                       CONSTRAINT rhn_pkg_supp_package_fk
                           REFERENCES rhnPackage (id)
                           ON DELETE CASCADE,
    capability_id  NUMBER NOT NULL
                       CONSTRAINT rhn_pkg_supp_capability_fk
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

CREATE UNIQUE INDEX rhn_pkg_supp_pid_cid_s_uq
    ON rhnPackageSupplements (package_id, capability_id, sense)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_pkg_supp_cid_idx
    ON rhnPackageSupplements (capability_id)
    NOLOGGING
    TABLESPACE [[4m_tbs]];

