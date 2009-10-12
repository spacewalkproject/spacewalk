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


CREATE TABLE rhnPackage
(
    id               NUMBER NOT NULL
                         CONSTRAINT rhn_package_id_pk PRIMARY KEY
                         USING INDEX TABLESPACE [[4m_tbs]],
    org_id           NUMBER
                         CONSTRAINT rhn_package_oid_fk
                             REFERENCES web_customer (id)
                             ON DELETE CASCADE,
    name_id          NUMBER NOT NULL
                         CONSTRAINT rhn_package_nid_fk
                             REFERENCES rhnPackageName (id),
    evr_id           NUMBER NOT NULL
                         CONSTRAINT rhn_package_eid_fk
                             REFERENCES rhnPackageEvr (id),
    package_arch_id  NUMBER NOT NULL
                         CONSTRAINT rhn_package_paid_fk
                             REFERENCES rhnPackageArch (id),
    package_group    NUMBER
                         CONSTRAINT rhn_package_group_fk
                             REFERENCES rhnPackageGroup (id),
    rpm_version      VARCHAR2(16),
    description      VARCHAR2(4000),
    summary          VARCHAR2(4000),
    package_size     NUMBER NOT NULL,
    payload_size     NUMBER,
    build_host       VARCHAR2(256),
    build_time       DATE,
    source_rpm_id    NUMBER
                         CONSTRAINT rhn_package_srcrpmid_fk
                             REFERENCES rhnSourceRPM (id),
    checksum_id      NUMBER NOT NULL
                         CONSTRAINT rhn_package_chsum_fk
                             REFERENCES rhnChecksum (id),
    vendor           VARCHAR2(64) NOT NULL,
    payload_format   VARCHAR2(32),
    compat           NUMBER(1)
                         DEFAULT (0)
                         CONSTRAINT rhn_package_compat_check
                             CHECK (compat in ( 1 , 0 )),
    path             VARCHAR2(1000),
    header_sig       VARCHAR2(64),
    copyright        VARCHAR2(128),
    cookie           VARCHAR2(128),
    last_modified    DATE
                         DEFAULT (sysdate) NOT NULL,
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    modified         DATE
                         DEFAULT (sysdate) NOT NULL,
    header_start     NUMBER
                         DEFAULT (-1) NOT NULL,
    header_end       NUMBER
                         DEFAULT (-1) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_package_oid_id_idx
    ON rhnPackage (org_id, id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_package_id_nid_paid_idx
    ON rhnPackage (id, name_id, package_arch_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_package_nid_id_idx
    ON rhnPackage (name_id, id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_package_path_idx
    ON rhnPackage(id, path)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_package_id_seq;

