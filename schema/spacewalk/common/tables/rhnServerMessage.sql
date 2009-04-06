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


CREATE TABLE rhnServerMessage
(
    server_id     NUMBER NOT NULL 
                      CONSTRAINT rhn_sm_server_id_fk
                          REFERENCES rhnServer (id), 
    message_id    NUMBER NOT NULL 
                      CONSTRAINT rhn_sm_message_id_fk
                          REFERENCES rhnMessage (id) 
                          ON DELETE CASCADE, 
    server_event  NUMBER 
                      CONSTRAINT rhn_sm_se_fk
                          REFERENCES rhnServerEvent (id) 
                          ON DELETE CASCADE, 
    created       DATE 
                      DEFAULT (sysdate) NOT NULL, 
    modified      DATE 
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_sm_uq
    ON rhnServerMessage (server_id, message_id)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_sm_mi_sid_uq
    ON rhnServerMessage (message_id, server_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX RHN_SRVR_MSSG_SRVR_EVNT_IDX
    ON rhnServerMessage (server_event)
    TABLESPACE [[64k_tbs]];

