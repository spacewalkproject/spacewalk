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


CREATE TABLE rhnServerNotes
(
    id         NUMBER NOT NULL
                   CONSTRAINT rhn_servernotes_id_pk PRIMARY KEY
                   USING INDEX TABLESPACE [[64k_tbs]],
    creator    NUMBER
                   CONSTRAINT rhn_servernotes_creator_fk
                       REFERENCES web_contact (id)
                       ON DELETE SET NULL,
    server_id  NUMBER NOT NULL
                   CONSTRAINT rhn_servernotes_sid_fk
                       REFERENCES rhnServer (id),
    subject    VARCHAR2(80) NOT NULL,
    note       VARCHAR2(4000),
    created    DATE
                   DEFAULT (sysdate) NOT NULL,
    modified   DATE
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_servernotes_sid_idx
    ON rhnServerNotes (server_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_servernotes_creator_idx
    ON rhnServerNotes (creator)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_server_note_id_seq;

