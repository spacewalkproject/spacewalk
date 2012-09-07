--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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


CREATE TABLE rhnChannelPackageArchCompat
(
    channel_arch_id  NUMBER NOT NULL
                         CONSTRAINT rhn_cp_ac_caid_fk
                             REFERENCES rhnChannelArch (id),
    package_arch_id  NUMBER NOT NULL
                         CONSTRAINT rhn_cp_ac_paid_fk
                             REFERENCES rhnPackageArch (id),
    created          timestamp with local time zone
                         DEFAULT (current_timestamp) NOT NULL,
    modified         timestamp with local time zone
                         DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_cp_ac_caid_paid
    ON rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhnChannelPackageArchCompat
    ADD CONSTRAINT rhn_cp_ac_caid_paid_uq UNIQUE (channel_arch_id, package_arch_id);

