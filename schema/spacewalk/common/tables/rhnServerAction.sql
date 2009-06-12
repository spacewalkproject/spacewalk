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


CREATE TABLE rhnServerAction
(
    server_id        NUMBER NOT NULL
                         CONSTRAINT rhn_server_action_sid_fk
                             REFERENCES rhnServer (id),
    action_id        NUMBER NOT NULL
                         CONSTRAINT rhn_server_action_aid_fk
                             REFERENCES rhnAction (id)
                             ON DELETE CASCADE,
    status           NUMBER NOT NULL
                         CONSTRAINT rhn_server_action_status_fk
                             REFERENCES rhnActionStatus (id),
    result_code      NUMBER,
    result_msg       VARCHAR2(1024),
    pickup_time      DATE,
    remaining_tries  NUMBER
                         DEFAULT (5) NOT NULL,
    completion_time  DATE,
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    modified         DATE
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_ser_act_sid_aid_s_idx
    ON rhnServerAction (server_id, action_id, status)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_ser_act_aid_sid_s_idx
    ON rhnServerAction (action_id, server_id, status)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;

ALTER TABLE rhnServerAction
    ADD CONSTRAINT rhn_server_action_sid_aid_uq UNIQUE (server_id, action_id);

