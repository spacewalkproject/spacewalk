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


CREATE TABLE rhnActionConfigChannel
(
    action_id          NUMBER NOT NULL 
                           CONSTRAINT rhn_actioncc_aid_fk
                               REFERENCES rhnAction (id) 
                               ON DELETE CASCADE, 
    server_id          NUMBER NOT NULL 
                           CONSTRAINT rhn_actioncc_sid_fk
                               REFERENCES rhnServer (id), 
    config_channel_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_actioncc_ccid_fk
                               REFERENCES rhnConfigChannel (id) 
                               ON DELETE CASCADE, 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_actioncc_aid_sid_uq
    ON rhnActionConfigChannel (action_id, server_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_actioncc_sid_aid_ccid_idx
    ON rhnActionConfigChannel (server_id, action_id, config_channel_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_act_cc_ccid_aid_sid_idx
    ON rhnActionConfigChannel (config_channel_id, action_id, server_id)
    TABLESPACE [[4m_tbs]];

ALTER TABLE rhnActionConfigChannel
    ADD CONSTRAINT rhn_actioncc_sid_aid_fk FOREIGN KEY (server_id, action_id)
    REFERENCES rhnServerAction (server_id, action_id) 
        ON DELETE CASCADE;

