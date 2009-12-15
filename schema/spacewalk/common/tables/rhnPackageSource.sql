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


CREATE TABLE rhnPackageSource
(
    id             NUMBER NOT NULL
                       CONSTRAINT rhn_pkgsrc_id_pk PRIMARY KEY
                       USING INDEX TABLESPACE [[64k_tbs]],
    org_id         NUMBER
                       CONSTRAINT rhn_pkgsrc_oid_fk
                           REFERENCES web_customer (id)
                           ON DELETE CASCADE,
    source_rpm_id  NUMBER NOT NULL
                       CONSTRAINT rhn_pkgsrc_srid_fk
                           REFERENCES rhnSourceRPM (id),
    package_group  NUMBER NOT NULL
                       CONSTRAINT rhn_pkgsrc_group_fk
                           REFERENCES rhnPackageGroup (id),
    rpm_version    VARCHAR2(16) NOT NULL,
    payload_size   NUMBER NOT NULL,
    build_host     VARCHAR2(256) NOT NULL,
    build_time     DATE NOT NULL,
    sigchecksum_id NUMBER NOT NULL
                      CONSTRAINT rhn_pkgsrc_sigchsum_fk
                          REFERENCES rhnChecksum (id),
    vendor         VARCHAR2(64) NOT NULL,
    cookie         VARCHAR2(128) NOT NULL,
    path           VARCHAR2(1000),
    checksum_id    NUMBER NOT NULL
                      CONSTRAINT rhn_pkgsrc_chsum_fk
                          REFERENCES rhnChecksum (id),
    package_size   NUMBER NOT NULL,
    last_modified  DATE
                       DEFAULT (sysdate) NOT NULL,
    created        DATE
                       DEFAULT (sysdate) NOT NULL,
    modified       DATE
                       DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_pkgsrc_srid_oid_uq
    ON rhnPackageSource (source_rpm_id, org_id)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_package_source_id_seq;

