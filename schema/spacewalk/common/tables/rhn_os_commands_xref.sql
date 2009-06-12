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


CREATE TABLE rhn_os_commands_xref
(
    os_id        NUMBER NOT NULL,
    commands_id  NUMBER NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_os_commands_xref IS 'oscxr  operating systems - commands cross ref';

CREATE UNIQUE INDEX rhn_oscxr_os_id_commands_id_pk
    ON rhn_os_commands_xref (os_id, commands_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_os_commands_xref
    ADD CONSTRAINT rhn_oscxr_os_id_commands_id_pk PRIMARY KEY (os_id, commands_id);

ALTER TABLE rhn_os_commands_xref
    ADD CONSTRAINT rhn_oscxr_cmmnd_commands_id_fk FOREIGN KEY (commands_id)
    REFERENCES rhn_command (recid);

ALTER TABLE rhn_os_commands_xref
    ADD CONSTRAINT rhn_oscxr_os000_os_id_fk FOREIGN KEY (os_id)
    REFERENCES rhn_os (recid);

