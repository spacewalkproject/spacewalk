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


CREATE TABLE rhnBlacklistObsoletes
(
    name_id          NUMBER NOT NULL
                         CONSTRAINT rhn_bl_obs_nid_fk
                             REFERENCES rhnPackageName (id),
    evr_id           NUMBER NOT NULL
                         CONSTRAINT rhn_bl_obs_eid_fk
                             REFERENCES rhnPackageEVR (id),
    package_arch_id  NUMBER NOT NULL
                         CONSTRAINT rhn_bl_obs_paid_fk
                             REFERENCES rhnPackageArch (id),
    ignore_name_id   NUMBER NOT NULL
                         CONSTRAINT rhn_bl_obs_inid_fk
                             REFERENCES rhnPackageName (id),
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    modified         DATE
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_bl_obs_nepi_idx
    ON rhnBlacklistObsoletes (name_id, evr_id, package_arch_id, ignore_name_id);

ALTER TABLE rhnBlacklistObsoletes
    ADD CONSTRAINT rhn_bl_obs_nepi_uq UNIQUE (name_id, evr_id, package_arch_id, ignore_name_id);

