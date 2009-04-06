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


CREATE TABLE rhnChannelNewestPackage
(
    channel_id       NUMBER NOT NULL 
                         CONSTRAINT rhn_cnp_cid_fk
                             REFERENCES rhnChannel (id) 
                             ON DELETE CASCADE, 
    name_id          NUMBER NOT NULL 
                         CONSTRAINT rhn_cnp_nid_fk
                             REFERENCES rhnPackageName (id), 
    evr_id           NUMBER NOT NULL 
                         CONSTRAINT rhn_cnp_eid_fk
                             REFERENCES rhnPackageEVR (id), 
    package_arch_id  NUMBER NOT NULL 
                         CONSTRAINT rhn_cnp_paid_fk
                             REFERENCES rhnPackageArch (id), 
    package_id       NUMBER NOT NULL 
                         CONSTRAINT rhn_cnp_pid_fk
                             REFERENCES rhnPackage (id) 
                             ON DELETE CASCADE
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_cnp_cnep_idx
    ON rhnChannelNewestPackage (channel_id, name_id, package_arch_id, evr_id, package_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_cnp_necp_idx
    ON rhnChannelNewestPackage (name_id, evr_id, channel_id, package_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_cnp_pid_idx
    ON rhnChannelNewestPackage (package_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhnChannelNewestPackage
    ADD CONSTRAINT rhn_cnp_cid_nid_uq UNIQUE (channel_id, name_id, package_arch_id);

