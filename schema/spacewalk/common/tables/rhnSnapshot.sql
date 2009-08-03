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


CREATE TABLE rhnSnapshot
(
    id         NUMBER NOT NULL
                   CONSTRAINT rhn_snapshot_id_pk PRIMARY KEY
                   USING INDEX TABLESPACE [[8m_tbs]],
    org_id     NUMBER NOT NULL
                   CONSTRAINT rhn_snapshot_oid_fk
                       REFERENCES web_customer (id),
    invalid    NUMBER
                   CONSTRAINT rhn_snapshot_invalid_fk
                       REFERENCES rhnSnapshotInvalidReason (id),
    reason     VARCHAR2(4000) NOT NULL,
    server_id  NUMBER NOT NULL
                   CONSTRAINT rhn_snapshot_sid_fk
                       REFERENCES rhnServer (id),
    created    DATE
                   DEFAULT (sysdate) NOT NULL,
    modified   DATE
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_snapshot_sid_idx
    ON rhnSnapshot (server_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_snapshot_oid_idx
    ON rhnSnapshot (org_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_snapshot_id_seq;

