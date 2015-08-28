--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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


CREATE TABLE rhnServerGroup
(
    id               NUMBER NOT NULL
                         CONSTRAINT rhn_servergroup_id_pk PRIMARY KEY
                         USING INDEX TABLESPACE [[4m_tbs]],
    name             VARCHAR2(64) NOT NULL,
    description      VARCHAR2(1024) NOT NULL,
    current_members  NUMBER
                         DEFAULT (0) NOT NULL,
    group_type       NUMBER
                         CONSTRAINT rhn_servergroup_type_fk
                             REFERENCES rhnServerGroupType (id),
    org_id           NUMBER NOT NULL
                         CONSTRAINT rhn_servergroup_oid_fk
                             REFERENCES web_customer (id)
                             ON DELETE CASCADE,
    created          timestamp with local time zone
                         DEFAULT (current_timestamp) NOT NULL,
    modified         timestamp with local time zone
                         DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_servergroup_oid_name_uq
    ON rhnServerGroup (org_id, name)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_sg_type_id_idx
    ON rhnServerGroup (group_type, id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_server_group_id_seq;

