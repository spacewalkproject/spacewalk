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


CREATE TABLE rhn_command_param_threshold
(
    command_id           NUMBER NOT NULL,
    param_name           VARCHAR2(40) NOT NULL,
    param_type           VARCHAR2(10) NOT NULL
                             CONSTRAINT rhn_coptr_param_type_ck
                                 CHECK (param_type = 'threshold'),
    threshold_type_name  VARCHAR2(10) NOT NULL,
    threshold_metric_id  VARCHAR2(40) NOT NULL,
    last_update_user     VARCHAR2(40),
    last_update_date     DATE,
    command_class        VARCHAR2(255) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command_param_threshold IS 'coptr  a parameter for a particular command';

CREATE UNIQUE INDEX rhn_coptr_id_p_name_p_type_pk
    ON rhn_command_param_threshold (command_id, param_name, param_type)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_command_param_threshold
    ADD CONSTRAINT rhn_coptr_id_p_name_p_type_pk PRIMARY KEY (command_id, param_name, param_type);

ALTER TABLE rhn_command_param_threshold
    ADD CONSTRAINT rhn_coptr_cmd_id_cmd_cl_fk FOREIGN KEY (command_id, command_class)
    REFERENCES rhn_command (recid, command_class)
        ON DELETE CASCADE;

ALTER TABLE rhn_command_param_threshold
    ADD CONSTRAINT rhn_coptr_m_thr_m_cmd_cl_fk FOREIGN KEY (command_class, threshold_metric_id)
    REFERENCES rhn_metrics (command_class, metric_id)
        ON DELETE CASCADE;

ALTER TABLE rhn_command_param_threshold
    ADD CONSTRAINT rhn_coptr_thrtp_thres_type_fk FOREIGN KEY (threshold_type_name)
    REFERENCES rhn_threshold_type (name);

