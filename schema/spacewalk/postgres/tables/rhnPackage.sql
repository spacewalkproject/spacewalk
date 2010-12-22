-- oracle equivalent source sha1 197aca2e6b8be7fa9aef2f9dfe3052e622cc4d22
--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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
    id               NUMERIC 
                         CONSTRAINT rhn_package_id_pk PRIMARY KEY,
    org_id           NUMERIC 
                         CONSTRAINT rhn_package_oid_fk
                             REFERENCES web_customer (id) 
                             ON DELETE CASCADE,
    name_id          NUMERIC NOT NULL 
                         CONSTRAINT rhn_package_nid_fk
                             REFERENCES rhnPackageName (id),
    evr_id           NUMERIC NOT NULL 
                         CONSTRAINT rhn_package_eid_fk
                             REFERENCES rhnPackageEvr (id),
    package_arch_id  NUMERIC NOT NULL 
                         CONSTRAINT rhn_package_paid_fk
                             REFERENCES rhnPackageArch (id),
    package_group    NUMERIC 
                         CONSTRAINT rhn_package_group_fk
                             REFERENCES rhnPackageGroup (id),
    rpm_version      VARCHAR(16),
    description      VARCHAR(4000),
    summary          VARCHAR(4000),
    package_size     NUMERIC NOT NULL,
    payload_size     NUMERIC,
    build_host       VARCHAR(256),
    build_time       TIMESTAMPTZ,
    source_rpm_id    NUMERIC 
                         CONSTRAINT rhn_package_srcrpmid_fk
                             REFERENCES rhnSourceRPM (id),
    checksum_id      NUMERIC NOT NULL 
                         CONSTRAINT rhn_package_chsum_fk
                             REFERENCES rhnChecksum (id),
    vendor           VARCHAR(64) NOT NULL,
    payload_format   VARCHAR(32),
    compat           SMALLINT 
                         DEFAULT (0) 
                         CONSTRAINT rhn_package_compat_check
                             CHECK (compat in ( 1 , 0 )),
    path             VARCHAR(1000),
    header_sig       VARCHAR(64),
    copyright        VARCHAR(128),
    cookie           VARCHAR(128),
    last_modified    TIMESTAMPTZ 
                         DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
    created          TIMESTAMPTZ 
                         DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
    modified         TIMESTAMPTZ 
                         DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
    header_start     NUMERIC 
                         DEFAULT (-1) NOT NULL,
    header_end       NUMERIC 
                         DEFAULT (-1) NOT NULL
)
;

CREATE INDEX rhn_package_oid_id_idx
    ON rhnPackage (org_id, id);

CREATE INDEX rhn_package_nid_id_idx
    ON rhnPackage (name_id, id);

CREATE SEQUENCE rhn_package_id_seq;

