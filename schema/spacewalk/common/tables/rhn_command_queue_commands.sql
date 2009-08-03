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


CREATE TABLE rhn_command_queue_commands
(
    recid             NUMBER(12) NOT NULL
                          CONSTRAINT rhn_cqcmd_recid_pk PRIMARY KEY
                          USING INDEX TABLESPACE [[2m_tbs]],
    description       VARCHAR2(40) NOT NULL,
    notes             VARCHAR2(2000),
    command_line      VARCHAR2(2000) NOT NULL,
    permanent         CHAR(1) NOT NULL,
    restartable       CHAR(1) NOT NULL,
    effective_user    VARCHAR2(40) NOT NULL,
    effective_group   VARCHAR2(40) NOT NULL,
    last_update_user  VARCHAR2(40),
    last_update_date  DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command_queue_commands IS 'cqcmd  command queue command definitions';

CREATE SEQUENCE rhn_command_q_comm_recid_seq START WITH 100;

