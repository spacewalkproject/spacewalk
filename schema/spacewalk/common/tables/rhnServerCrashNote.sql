--
-- Copyright (c) 2013 Red Hat, Inc.
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


CREATE TABLE rhnServerCrashNote
(
    id         NUMBER NOT NULL
                   CONSTRAINT rhn_server_crash_note_id_pk PRIMARY KEY
                   USING INDEX TABLESPACE [[64k_tbs]],
    creator    NUMBER
                   CONSTRAINT rhn_srv_crash_note_creator_fk
                       REFERENCES web_contact (id)
                       ON DELETE SET NULL,
    crash_id  NUMBER NOT NULL
                   CONSTRAINT rhn_srv_crash_note_sid_fk
                       REFERENCES rhnServerCrash (id)
                       ON DELETE CASCADE,
    subject    VARCHAR2(80) NOT NULL,
    note       VARCHAR2(4000),
    created    timestamp with local time zone
                   DEFAULT (current_timestamp) NOT NULL,
    modified   timestamp with local time zone
                   DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_srv_crash_note_sid_idx
    ON rhnServerCrashNote (crash_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_srv_crash_note_creator_idx
    ON rhnServerCrashNote (creator)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_srv_crash_note_id_seq;
