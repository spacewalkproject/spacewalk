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


CREATE TABLE rhnServerActionVerifyMissing
(
    server_id              NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvm_sid_fk
                                   REFERENCES rhnServer (id),
    action_id              NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvm_aid_fk
                                   REFERENCES rhnAction (id)
                                   ON DELETE CASCADE,
    package_name_id        NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvm_pnid_fk
                                   REFERENCES rhnPackageName (id),
    package_evr_id         NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvm_peid_fk
                                   REFERENCES rhnPackageevr (id),
    package_arch_id        NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvm_paid_fk
                                   REFERENCES rhnPackageArch (id),
    package_capability_id  NUMBER NOT NULL
                               CONSTRAINT rhn_sactionvm_pcid_fk
                                   REFERENCES rhnPackageCapability (id),
    created                DATE
                               DEFAULT (sysdate) NOT NULL,
    modified               DATE
                               DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_sactionvm_sanec_uq
    ON rhnServerActionVerifyMissing (server_id, action_id, package_name_id, package_evr_id, package_arch_id, package_capability_id)
    TABLESPACE [[4m_tbs]];

