--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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


CREATE TABLE rhn_command_parameter
(
    command_id             NUMBER NOT NULL,
    param_name             VARCHAR2(40) NOT NULL,
    param_type             VARCHAR2(10)
                               DEFAULT ('config') NOT NULL,
    data_type_name         VARCHAR2(10) NOT NULL,
    description            VARCHAR2(80) NOT NULL,
    mandatory              CHAR(1)
                               DEFAULT ('0') NOT NULL,
    default_value          VARCHAR2(1024),
    min_value              NUMBER,
    max_value              NUMBER,
    field_order            NUMBER NOT NULL,
    field_widget_name      VARCHAR2(20) NOT NULL,
    field_visible_length   NUMBER,
    field_maximum_length   NUMBER,
    field_visible          CHAR(1)
                               DEFAULT ('1') NOT NULL,
    default_value_visible  CHAR(1)
                               DEFAULT ('1') NOT NULL,
    last_update_user       VARCHAR2(40),
    last_update_date       DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command_parameter IS 'CPARM  A parameter for a particular command';

COMMENT ON COLUMN rhn_command_parameter.field_visible IS 'if default is $HOSTADDRESS$, param is marked as default not visible ';

CREATE UNIQUE INDEX rhn_cparm_cmd_id_param_name_uq
    ON rhn_command_parameter (command_id, param_name)
    TABLESPACE [[2m_tbs]];

CREATE UNIQUE INDEX rhn_cparm_id_p_name_p_type_uq
    ON rhn_command_parameter (command_id, param_name, param_type)
    TABLESPACE [[2m_tbs]];

CREATE UNIQUE INDEX rhn_cparm_cmd_id_field_orde_uq
    ON rhn_command_parameter (command_id, field_order)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_command_parameter
    ADD CONSTRAINT rhn_cparm_id_parm_name_pk PRIMARY KEY (command_id, param_name);

ALTER TABLE rhn_command_parameter
    ADD CONSTRAINT rhn_cparm_id_p_name_p_type_uq UNIQUE (command_id, param_name, param_type);

ALTER TABLE rhn_command_parameter
    ADD CONSTRAINT rhn_cparm_id_field_orde_uq UNIQUE (command_id, field_order);

ALTER TABLE rhn_command_parameter
    ADD CONSTRAINT rhn_cparm_cmd_command_id_fk FOREIGN KEY (command_id)
    REFERENCES rhn_command (recid)
        ON DELETE CASCADE;

ALTER TABLE rhn_command_parameter
    ADD CONSTRAINT rhn_cparm_sdtyp_name_fk FOREIGN KEY (data_type_name)
    REFERENCES rhn_semantic_data_type (name);

ALTER TABLE rhn_command_parameter
    ADD CONSTRAINT rhn_cparm_wdgt_fld_wdgt_n_fk FOREIGN KEY (field_widget_name)
    REFERENCES rhn_widget (name);

