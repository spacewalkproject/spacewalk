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


CREATE TABLE rhnPathChannelMap
(
    path        VARCHAR2(128) NOT NULL, 
    channel_id  NUMBER NOT NULL 
                    CONSTRAINT rhn_path_channel_map_cid_fk
                        REFERENCES rhnChannel (id) 
                        ON DELETE CASCADE, 
    is_source   VARCHAR2(1), 
    created     DATE 
                    DEFAULT (SYSDATE), 
    modified    DATE 
                    DEFAULT (SYSDATE)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_path_channel_map_p_cid_uq
    ON rhnPathChannelMap (path, channel_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_path_channel_map_cid_p_idx
    ON rhnPathChannelMap (channel_id, path)
    TABLESPACE [[64k_tbs]]
    LOGGING;

