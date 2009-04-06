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


CREATE TABLE rhnKickstartSession
(
    id                   NUMBER NOT NULL 
                             CONSTRAINT rhn_ks_session_id_pk PRIMARY KEY 
                             USING INDEX TABLESPACE [[8m_tbs]], 
    kickstart_id         NUMBER 
                             CONSTRAINT rhn_ks_session_ksid_fk
                                 REFERENCES rhnKSData (id) 
                                 ON DELETE CASCADE, 
    kickstart_mode       VARCHAR2(32), 
    kstree_id            NUMBER 
                             CONSTRAINT rhn_ks_session_kstid_fk
                                 REFERENCES rhnKickstartableTree (id) 
                                 ON DELETE SET NULL, 
    org_id               NUMBER NOT NULL 
                             CONSTRAINT rhn_ks_session_oid_fk
                                 REFERENCES web_customer (id) 
                                 ON DELETE CASCADE, 
    scheduler            NUMBER 
                             CONSTRAINT rhn_ks_session_sched_fk
                                 REFERENCES web_contact (id) 
                                 ON DELETE SET NULL, 
    old_server_id        NUMBER 
                             CONSTRAINT rhn_ks_session_osid_fk
                                 REFERENCES rhnServer (id), 
    new_server_id        NUMBER 
                             CONSTRAINT rhn_ks_session_nsid_fk
                                 REFERENCES rhnServer (id), 
    host_server_id       NUMBER 
                             CONSTRAINT rhn_ks_session_hsid_fk
                                 REFERENCES rhnServer (id) 
                                 ON DELETE CASCADE, 
    action_id            NUMBER 
                             CONSTRAINT rhn_ks_session_aid_fk
                                 REFERENCES rhnAction (id) 
                                 ON DELETE SET NULL, 
    state_id             NUMBER NOT NULL 
                             CONSTRAINT rhn_ks_session_ksssid_fk
                                 REFERENCES rhnKickstartSessionState (id), 
    server_profile_id    NUMBER 
                             CONSTRAINT rhn_ks_session_spid_fk
                                 REFERENCES rhnServerProfile (id) 
                                 ON DELETE SET NULL, 
    last_action          DATE 
                             DEFAULT (sysdate) NOT NULL, 
    package_fetch_count  NUMBER 
                             DEFAULT (0) NOT NULL, 
    last_file_request    VARCHAR2(2048), 
    system_rhn_host      VARCHAR2(256), 
    kickstart_from_host  VARCHAR2(256), 
    deploy_configs       CHAR(1) 
                             DEFAULT ('N') NOT NULL, 
    virtualization_type  NUMBER NOT NULL 
                             CONSTRAINT rhn_kss_kvt_fk
                                 REFERENCES rhnKickstartVirtualizationType (id) 
                                 ON DELETE SET NULL, 
    client_ip            VARCHAR2(15), 
    created              DATE 
                             DEFAULT (sysdate) NOT NULL, 
    modified             DATE 
                             DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_ks_session_oid_idx
    ON rhnKickstartSession (org_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_ks_session_osid_aid_idx
    ON rhnKickstartSession (old_server_id, action_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_ks_session_nsid_idx
    ON rhnKickstartSession (new_server_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_ks_session_hsid_idx
    ON rhnKickstartSession (host_server_id)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_ks_session_id_seq;

