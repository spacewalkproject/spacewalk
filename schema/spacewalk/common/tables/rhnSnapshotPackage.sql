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


CREATE TABLE rhnSnapshotPackage
(
    snapshot_id  NUMBER NOT NULL 
                     CONSTRAINT rhn_snapshotpkg_sid_fk
                         REFERENCES rhnSnapshot (id) 
                         ON DELETE CASCADE, 
    nevra_id     NUMBER NOT NULL 
                     CONSTRAINT rhn_snapshotpkg_nid_fk
                         REFERENCES rhnPackageNevra (id)
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_snapshotpkg_sid
    ON rhnSnapshotPackage (snapshot_id)
    TABLESPACE [[8m_tbs]];

CREATE UNIQUE INDEX rhn_snapshotpkg_sid_nid_uq
    ON rhnSnapshotPackage (snapshot_id, nevra_id)
    TABLESPACE [[32m_tbs]];

