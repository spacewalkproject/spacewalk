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


CREATE TABLE rhnAppInstallSession
(
    id            NUMBER NOT NULL,
    instance_id   NUMBER NOT NULL
                      CONSTRAINT rhn_appinst_session_iid_fk
                          REFERENCES rhnAppInstallInstance (id)
                          ON DELETE CASCADE,
    checksum_id   NUMBER NOT NULL
                     CONSTRAINT rhn_appinst_session_chsum_fk
                     REFERENCES rhnChecksum (id),
    process_name  VARCHAR2(32),
    step_number   NUMBER,
    user_id       NUMBER NOT NULL
                      CONSTRAINT rhn_appinst_session_uid_fk
                          REFERENCES web_contact (id),
    server_id     NUMBER NOT NULL
                      CONSTRAINT rhn_appinst_session_sid_fk
                          REFERENCES rhnServer (id),
    created       DATE
                      DEFAULT (sysdate) NOT NULL,
    modified      DATE
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_appinst_session_id_iid_idx
    ON rhnAppInstallSession (id, instance_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_appinst_session_iid_id_idx
    ON rhnAppInstallSession (instance_id, id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_appinst_sessn_uid_iid_idx
    ON rhnAppInstallSession (user_id, instance_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_appinst_sessn_sid_iid_idx
    ON rhnAppInstallSession (server_id, instance_id)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_appinst_session_id_seq;

ALTER TABLE rhnAppInstallSession
    ADD CONSTRAINT rhn_appinst_sessiond_id_pk PRIMARY KEY (id);

