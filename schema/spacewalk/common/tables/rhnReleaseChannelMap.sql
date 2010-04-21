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


CREATE TABLE rhnReleaseChannelMap
(
    product          VARCHAR2(64) NOT NULL,
    version          VARCHAR2(64) NOT NULL,
    release          VARCHAR2(64) NOT NULL,
    channel_arch_id  NUMBER NOT NULL
                     CONSTRAINT rhn_rcm_caid_fk
                        REFERENCES rhnChannelArch (id),
    channel_id       NUMBER NOT NULL
                     CONSTRAINT rhn_rcm_cid_fk
                        REFERENCES rhnChannel (id)
                        ON DELETE CASCADE
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_rcm_prod_ver_rel_caid_idx
    ON rhnReleaseChannelMap (product, version, release, channel_arch_id)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhnReleaseChannelMap
    ADD CONSTRAINT rhn_rcm_pva_def_uniq
    UNIQUE (product, version, channel_arch_id, release);
