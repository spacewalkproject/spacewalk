--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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


CREATE TABLE rhnActionConfigFileName
(
    action_id            NUMBER NOT NULL,
    server_id            NUMBER NOT NULL,
    config_file_name_id  NUMBER NOT NULL
                             CONSTRAINT rhn_actioncf_name_cfnid_fk
                                 REFERENCES rhnConfigFileName (id),
    config_revision_id   NUMBER
                             CONSTRAINT rhn_actioncf_name_crid_fk
                                 REFERENCES rhnConfigRevision (id)
                                 ON DELETE SET NULL,
    failure_id           NUMBER
                             CONSTRAINT rhn_actioncf_failure_id_fk
                                 REFERENCES rhnConfigFileFailure (id),
    created              timestamp with local time zone
                             DEFAULT (current_timestamp) NOT NULL,
    modified             timestamp with local time zone
                             DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_actioncf_name_asc_uq
    ON rhnActionConfigFileName (action_id, server_id, config_file_name_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_actioncf_name_sid_idx
    ON rhnActionConfigFileName (server_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_act_cnfg_fn_crid_idx
    ON rhnActionConfigFileName (config_revision_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhnActionConfigFileName
    ADD CONSTRAINT rhn_actioncf_name_aid_sid_fk FOREIGN KEY (server_id, action_id)
    REFERENCES rhnServerAction (server_id, action_id)
        ON DELETE CASCADE;

