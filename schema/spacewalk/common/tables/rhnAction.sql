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


CREATE TABLE rhnAction
(
    id               NUMBER NOT NULL
                         CONSTRAINT rhn_action_pk PRIMARY KEY
                         USING INDEX TABLESPACE [[4m_tbs]],
    org_id           NUMBER NOT NULL
                         CONSTRAINT rhn_action_oid_fk
                             REFERENCES web_customer (id)
                             ON DELETE CASCADE,
    action_type      NUMBER NOT NULL
                         CONSTRAINT rhn_action_at_fk
                             REFERENCES rhnActionType (id),
    name             VARCHAR2(128),
    scheduler        NUMBER
                         CONSTRAINT rhn_action_scheduler_fk
                             REFERENCES web_contact (id)
                             ON DELETE SET NULL,
    earliest_action  DATE NOT NULL,
    version          NUMBER
                         DEFAULT (0) NOT NULL,
    archived         NUMBER
                         DEFAULT (0) NOT NULL
                         CONSTRAINT rhn_action_archived_ck
                             CHECK (archived in ( 0 , 1 )),
    prerequisite     NUMBER
                         CONSTRAINT rhn_action_prereq_fk
                             REFERENCES rhnAction (id)
                             ON DELETE CASCADE,
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    modified         DATE
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_action_oid_idx
    ON rhnAction (org_id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_action_scheduler_idx
    ON rhnAction (scheduler)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_action_prereq_id_idx
    ON rhnAction (prerequisite, id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_event_id_seq;

