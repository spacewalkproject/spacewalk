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


CREATE TABLE rhnKickstartCommand
(
    id                  NUMBER
                            CONSTRAINT rhn_kscommand_id_pk PRIMARY KEY
                            USING INDEX TABLESPACE [[4m_tbs]],
    kickstart_id        NUMBER NOT NULL
                            CONSTRAINT rhn_kscommand_ksid_fk
                                REFERENCES rhnKSData (id)
                                ON DELETE CASCADE,
    ks_command_name_id  NUMBER NOT NULL
                            CONSTRAINT rhn_kscommand_kcnid_fk
                                REFERENCES rhnKickstartCommandName (id),
    arguments           VARCHAR2(2048),
    created             DATE
                            DEFAULT (sysdate) NOT NULL,
    modified            DATE
                            DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_kscommand_ksid_idx
    ON rhnKickstartCommand (kickstart_id)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_kscommand_id_seq;

