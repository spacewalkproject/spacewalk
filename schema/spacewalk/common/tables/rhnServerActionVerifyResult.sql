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


CREATE TABLE rhnServerActionVerifyResult
(
    server_id              NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvr_sid_fk
                                   REFERENCES rhnServer (id),
    action_id              NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvr_aid_fk
                                   REFERENCES rhnAction (id)
                                   ON DELETE CASCADE,
    package_name_id        NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvr_pnid_fk
                                   REFERENCES rhnPackageName (id),
    package_evr_id         NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvr_peid_fk
                                   REFERENCES rhnPackageEVR (id),
    package_arch_id        NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvr_paid_fk
                                   REFERENCES rhnPackageArch (id),
    package_capability_id  NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvr_pcid_fk
                                   REFERENCES rhnPackageCapability (id),
    attribute              CHAR(1)
                               CONSTRAINT rhn_sactionvr_attr_ck
                                   CHECK (attribute in ( 'c' , 'd' , 'g' , 'l' , 'r' )),
    size_differs           CHAR(1) NOT NULL
                               CONSTRAINT rhn_sactionvr_size_ck
                                   CHECK (size_differs in ( 'Y' , 'N' , '?' )),
    mode_differs           CHAR(1) NOT NULL
                               CONSTRAINT rhn_sactionvr_mode_ck
                                   CHECK (mode_differs in ( 'Y' , 'N' , '?' )),
    checksum_differs       CHAR(1) NOT NULL
                               CONSTRAINT rhn_sactionvr_chsum_ck
                                   CHECK (checksum_differs in ( 'Y' , 'N' , '?' )),
    devnum_differs         CHAR(1) NOT NULL
                               CONSTRAINT rhn_sactionvr_devnum_ck
                                   CHECK (devnum_differs in ( 'Y' , 'N' , '?' )),
    readlink_differs       CHAR(1) NOT NULL
                               CONSTRAINT rhn_sactionvr_readlink_ck
                                   CHECK (readlink_differs in ( 'Y' , 'N' , '?' )),
    uid_differs            CHAR(1) NOT NULL
                               CONSTRAINT rhn_sactionvr_uid_ck
                                   CHECK (uid_differs in ( 'Y' , 'N' , '?' )),
    gid_differs            CHAR(1) NOT NULL
                               CONSTRAINT rhn_sactionvr_gid_ck
                                   CHECK (gid_differs in ( 'Y' , 'N' , '?' )),
    mtime_differs          CHAR(1) NOT NULL
                               CONSTRAINT rhn_sactionvr_mtime_ck
                                   CHECK (mtime_differs in ( 'Y' , 'N' , '?' )),
    created                DATE
                               DEFAULT (sysdate) NOT NULL,
    modified               DATE
                               DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_sactionvr_sanec_uq
    ON rhnServerActionVerifyResult (server_id, action_id, package_name_id, package_evr_id, package_arch_id, package_capability_id)
    TABLESPACE [[4m_tbs]];

