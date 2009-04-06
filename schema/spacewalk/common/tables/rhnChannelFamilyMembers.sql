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


CREATE TABLE rhnChannelFamilyMembers
(
    channel_id         NUMBER NOT NULL 
                           CONSTRAINT rhn_cf_members_c_fk
                               REFERENCES rhnChannel (id) 
                               ON DELETE CASCADE, 
    channel_family_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_cf_family_fk
                               REFERENCES rhnChannelFamily (id), 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_cf_member_uq
    ON rhnChannelFamilyMembers (channel_id, channel_family_id)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_cf_c_uq
    ON rhnChannelFamilyMembers (channel_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_cf_member_cf_c_idx
    ON rhnChannelFamilyMembers (channel_family_id, channel_id)
    TABLESPACE [[64k_tbs]]
    LOGGING;

