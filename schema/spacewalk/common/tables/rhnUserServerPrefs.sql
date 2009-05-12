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


CREATE TABLE rhnUserServerPrefs
(
    user_id    NUMBER NOT NULL 
                   CONSTRAINT rhn_userServerPrefs_uid_fk
                       REFERENCES web_contact (id) 
                       ON DELETE CASCADE, 
    server_id  NUMBER NOT NULL 
                   CONSTRAINT rhn_userServerPrefs_sid_fk
                       REFERENCES rhnServer (id), 
    name       VARCHAR2(64) NOT NULL, 
    value      VARCHAR2(1) NOT NULL, 
    created    DATE 
                   DEFAULT (sysdate) NOT NULL, 
    modified   DATE 
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_usprefs_uid_sid_n_uq
    ON rhnUserServerPrefs (user_id, server_id, name)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_usprefs_n_sid_uid_idx
    ON rhnUserServerPrefs (name, server_id, user_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_usprefs_sid_uid_n_idx
    ON rhnUserServerPrefs (server_id, user_id, name)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

