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


CREATE TABLE rhnAppInstallSessionData
(
    id          NUMBER NOT NULL,
    session_id  NUMBER NOT NULL
                    CONSTRAINT rhn_appinst_sdata_sid_fk
                        REFERENCES rhnAppInstallSession (id)
                        ON DELETE CASCADE,
    key         VARCHAR2(64) NOT NULL,
    value       VARCHAR2(2048),
    extra_data  BLOB,
    created     DATE
                    DEFAULT (sysdate) NOT NULL,
    modified    DATE
                    DEFAULT (sysdate) NOT NULL
)
TABLESPACE [[blob]]
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_appinst_sdata_id_idx
    ON rhnAppInstallSessionData (id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_appinst_sdata_sid_k_id_idx
    ON rhnAppInstallSessionData (session_id, key, id)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_appinst_sdata_id_seq;

ALTER TABLE rhnAppInstallSessionData
    ADD CONSTRAINT rhn_appinst_sdata_id_pk PRIMARY KEY (id);

ALTER TABLE rhnAppInstallSessionData
    ADD CONSTRAINT rhn_appinst_sdata_sid_k_uq UNIQUE (session_id, key);

