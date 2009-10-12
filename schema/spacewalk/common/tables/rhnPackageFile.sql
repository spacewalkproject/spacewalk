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


CREATE TABLE rhnPackageFile
(
    package_id     NUMBER NOT NULL
                       CONSTRAINT rhn_package_file_pid_fk
                           REFERENCES rhnPackage (id)
                           ON DELETE CASCADE,
    capability_id  NUMBER NOT NULL
                       CONSTRAINT rhn_package_file_cid_fk
                           REFERENCES rhnPackageCapability (id),
    device         NUMBER NOT NULL,
    inode          NUMBER NOT NULL,
    file_mode      NUMBER NOT NULL,
    username       VARCHAR2(32) NOT NULL,
    groupname      VARCHAR2(32) NOT NULL,
    rdev           NUMBER NOT NULL,
    file_size      NUMBER NOT NULL,
    mtime          DATE NOT NULL,
    checksum_id    NUMBER NOT NULL
                      CONSTRAINT rhn_package_file_chsum_fk
                          REFERENCES rhnChecksum (id),
    linkto         VARCHAR2(256),
    flags          NUMBER NOT NULL,
    verifyflags    NUMBER NOT NULL,
    lang           VARCHAR2(32),
    created        DATE
                       DEFAULT (sysdate) NOT NULL,
    modified       DATE
                       DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_package_file_pid_cid_uq
    ON rhnPackageFile (package_id, capability_id)
    TABLESPACE [[32m_tbs]];

CREATE INDEX rhn_package_file_cid_pid_idx
    ON rhnPackageFile (capability_id, package_id)
    TABLESPACE [[32m_tbs]]
    NOLOGGING;

