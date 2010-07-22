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


CREATE TABLE rhn_command
(
    recid                NUMBER NOT NULL
                             CONSTRAINT rhn_cmmnd_recid_pk PRIMARY KEY
                             USING INDEX TABLESPACE [[2m_tbs]],
    name                 VARCHAR2(40) NOT NULL,
    description          VARCHAR2(80) NOT NULL,
    group_name           VARCHAR2(40),
    allowed_in_suite     CHAR(1)
                             DEFAULT ('1') NOT NULL,
    command_class        VARCHAR2(255)
                             DEFAULT ('/var/lib/nocpulse/libexec/plugin') NOT NULL,
    enabled              CHAR(1)
                             DEFAULT ('1') NOT NULL,
    for_host_probe       CHAR(1)
                             DEFAULT ('0') NOT NULL,
    last_update_user     VARCHAR2(40),
    last_update_date     DATE,
    system_requirements  VARCHAR2(40),
    version_support      VARCHAR2(1024),
    help_url             VARCHAR2(1024)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command IS 'CMMND A command that probes can run';

COMMENT ON COLUMN rhn_command.command_class IS 'Program to run ';

COMMENT ON COLUMN rhn_command.enabled IS 'Whether command should be usable';

COMMENT ON COLUMN rhn_command.for_host_probe IS 'Whether this is one of the host-alive checks';

CREATE UNIQUE INDEX rhn_cmmnd_name_uq
    ON rhn_command (name)
    TABLESPACE [[2m_tbs]];

CREATE UNIQUE INDEX rhn_cmmnd_recid_comm_cl_uq
    ON rhn_command (recid, command_class)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_commands_recid_seq START WITH 305;

ALTER TABLE rhn_command
    ADD CONSTRAINT rhn_cmmnd_recid_comm_cl_uq UNIQUE (recid, command_class);

ALTER TABLE rhn_command
    ADD CONSTRAINT rhn_cmmnd_cmdgr_group_name_fk FOREIGN KEY (group_name)
    REFERENCES rhn_command_groups (group_name);

ALTER TABLE rhn_command
    ADD CONSTRAINT rhn_cmmnd_comcl_class_name_fk FOREIGN KEY (command_class)
    REFERENCES rhn_command_class (class_name);

ALTER TABLE rhn_command
    ADD CONSTRAINT rhn_cmmnd_sys_reqs_fk FOREIGN KEY (system_requirements)
    REFERENCES rhn_command_requirements (name)
        ON DELETE CASCADE;

