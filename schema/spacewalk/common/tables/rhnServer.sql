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


CREATE TABLE rhnServer
(
    id                  NUMBER NOT NULL 
                            CONSTRAINT rhn_server_id_pk PRIMARY KEY 
                            USING INDEX TABLESPACE [[4m_tbs]], 
    org_id              NUMBER NOT NULL 
                            CONSTRAINT rhn_server_oid_fk
                                REFERENCES web_customer (id) 
                                ON DELETE CASCADE, 
    digital_server_id   VARCHAR2(64) NOT NULL, 
    server_arch_id      NUMBER NOT NULL 
                            CONSTRAINT rhn_server_said_fk
                                REFERENCES rhnServerArch (id), 
    os                  VARCHAR2(64) NOT NULL, 
    release             VARCHAR2(64) NOT NULL, 
    name                VARCHAR2(128), 
    description         VARCHAR2(256), 
    info                VARCHAR2(128), 
    secret              VARCHAR2(32) NOT NULL, 
    creator_id          NUMBER 
                            CONSTRAINT rhn_server_creator_fk
                                REFERENCES web_contact (id) 
                                ON DELETE SET NULL, 
    auto_deliver        CHAR(1) 
                            DEFAULT ('N') NOT NULL 
                            CONSTRAINT rhn_server_deliver_ck
                                CHECK (auto_deliver in ( 'Y' , 'N' )), 
    auto_update         CHAR(1) 
                            DEFAULT ('N') NOT NULL 
                            CONSTRAINT rhn_server_update_ck
                                CHECK (auto_update in ( 'Y' , 'N' )), 
    running_kernel      VARCHAR2(64), 
    last_boot           NUMBER 
                            DEFAULT (0) NOT NULL, 
    provision_state_id  NUMBER 
                            CONSTRAINT rhn_server_psid_fk
                                REFERENCES rhnProvisionState (id), 
    channels_changed    DATE, 
    cobbler_id          VARCHAR2(64), 
    created             DATE 
                            DEFAULT (sysdate) NOT NULL, 
    modified            DATE 
                            DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_server_dsid_uq
    ON rhnServer (digital_server_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_server_oid_id_idx
    ON rhnServer (org_id, id)
    TABLESPACE [[4m_tbs]]
    LOGGING;

CREATE INDEX rhn_server_created_id_idx
    ON rhnServer (created, id)
    TABLESPACE [[4m_tbs]]
    LOGGING;

CREATE INDEX rhn_server_creator_idx
    ON rhnServer (creator_id)
    TABLESPACE [[2m_tbs]]
    LOGGING;

CREATE SEQUENCE rhn_server_id_seq START WITH 1000010000 ORDER;

