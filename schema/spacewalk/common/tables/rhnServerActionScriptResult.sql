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


CREATE TABLE rhnServerActionScriptResult
(
    server_id         NUMBER NOT NULL
                          CONSTRAINT rhn_serveras_result_sid_fk
                              REFERENCES rhnServer (id),
    action_script_id  NUMBER NOT NULL
                          CONSTRAINT rhn_serveras_result_asid_fk
                              REFERENCES rhnActionScript (id)
                              ON DELETE CASCADE,
    output            BLOB,
    start_date        DATE NOT NULL,
    stop_date         DATE NOT NULL,
    return_code       NUMBER NOT NULL,
    created           DATE
                          DEFAULT (sysdate) NOT NULL,
    modified          DATE
                          DEFAULT (sysdate) NOT NULL
)
TABLESPACE [[blob]]
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_serveras_result_sas_uq
    ON rhnServerActionScriptResult (server_id, action_script_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_serveras_result_asid_idx
    ON rhnServerActionScriptResult (action_script_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;

