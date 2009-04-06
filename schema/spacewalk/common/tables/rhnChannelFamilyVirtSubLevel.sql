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


CREATE TABLE rhnChannelFamilyVirtSubLevel
(
    channel_family_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_cfvsl_cfid_fk
                               REFERENCES rhnChannelFamily (id), 
    virt_sub_level_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_cfvsl_vslid_fk
                               REFERENCES rhnVirtSubLevel (id), 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_cfvsl_cfid_vslid_idx
    ON rhnChannelFamilyVirtSubLevel (channel_family_id, virt_sub_level_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_cfvsl_vslid_cfid_idx
    ON rhnChannelFamilyVirtSubLevel (virt_sub_level_id, channel_family_id)
    TABLESPACE [[64k_tbs]];

