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


CREATE TABLE rhn_probe_param_value
(
    probe_id          NUMBER NOT NULL,
    command_id        NUMBER NOT NULL,
    param_name        VARCHAR2(40) NOT NULL,
    value             VARCHAR2(1024),
    last_update_user  VARCHAR2(40),
    last_update_date  DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_probe_param_value IS 'ppval  param value for a probe running a command';

CREATE UNIQUE INDEX rhn_ppval_p_id_cmd_id_parm_pk
    ON rhn_probe_param_value (probe_id, command_id, param_name)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_probe_param_value
    ADD CONSTRAINT rhn_ppval_p_id_cmd_id_parm_pk PRIMARY KEY (probe_id, command_id, param_name);

ALTER TABLE rhn_probe_param_value
    ADD CONSTRAINT rhn_ppval_chkpb_probe_id_fk FOREIGN KEY (probe_id)
    REFERENCES rhn_probe (recid)
        ON DELETE CASCADE;

ALTER TABLE rhn_probe_param_value
    ADD CONSTRAINT rhn_ppval_cmd_id_parm_nm_fk FOREIGN KEY (command_id, param_name)
    REFERENCES rhn_command_parameter (command_id, param_name)
        ON DELETE CASCADE;

