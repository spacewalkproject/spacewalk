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


CREATE TABLE rhnSatelliteInfo
(
    server_id          NUMBER NOT NULL 
                           CONSTRAINT rhn_satellite_info_sid_fk
                               REFERENCES rhnServer (id), 
    evr_id             NUMBER 
                           CONSTRAINT rhn_satellite_info_eid_fk
                               REFERENCES rhnPackageEVR (id), 
    cert               BLOB NOT NULL, 
    product            VARCHAR2(256) NOT NULL, 
    owner              VARCHAR2(256) NOT NULL, 
    issued_string      VARCHAR2(256), 
    expiration_string  VARCHAR2(256), 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_satellite_info_sid_idx
    ON rhnSatelliteInfo (server_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhnSatelliteInfo
    ADD CONSTRAINT rhn_satellite_info_sid_uq UNIQUE (server_id);

