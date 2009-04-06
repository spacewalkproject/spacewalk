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


CREATE TABLE rhnSatelliteChannelFamily
(
    server_id          NUMBER NOT NULL 
                           CONSTRAINT rhn_sat_cf_sid_fk
                               REFERENCES rhnServer (id), 
    channel_family_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_sat_cf_cfid_fk
                               REFERENCES rhnChannelFamily (id) 
                               ON DELETE CASCADE, 
    quantity           NUMBER, 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_sat_cf_sid_cfid_idx
    ON rhnSatelliteChannelFamily (server_id, channel_family_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_sat_cf_cfid_sid_idx
    ON rhnSatelliteChannelFamily (channel_family_id, server_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhnSatelliteChannelFamily
    ADD CONSTRAINT rhn_sat_cf_sid_cfid_uq UNIQUE (server_id, channel_family_id);

