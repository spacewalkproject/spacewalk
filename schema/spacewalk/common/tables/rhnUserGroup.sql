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


CREATE TABLE rhnUserGroup
(
    id               NUMBER NOT NULL 
                         CONSTRAINT rhn_user_group_pk PRIMARY KEY 
                         USING INDEX TABLESPACE [[8m_tbs]], 
    name             VARCHAR2(64) NOT NULL, 
    description      VARCHAR2(1024) NOT NULL, 
    max_members      NUMBER, 
    current_members  NUMBER 
                         DEFAULT (0) NOT NULL, 
    group_type       NUMBER NOT NULL 
                         CONSTRAINT rhn_usergroup_type_fk
                             REFERENCES rhnUserGroupType (id), 
    org_id           NUMBER NOT NULL 
                         CONSTRAINT rhn_user_group_org_fk
                             REFERENCES web_customer (id) 
                             ON DELETE CASCADE, 
    created          DATE 
                         DEFAULT (sysdate) NOT NULL, 
    modified         DATE 
                         DEFAULT (sysdate) NOT NULL, 
    CONSTRAINT rhn_ug_oid_gt_uq UNIQUE (org_id, group_type)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_ug_oid_name_uq
    ON rhnUserGroup (org_id, name)
    TABLESPACE [[32m_tbs]];

CREATE INDEX rhn_ug_id_name_org
    ON rhnUserGroup (id, name, org_id)
    TABLESPACE [[32m_tbs]]
    LOGGING;

CREATE INDEX rhn_ug_org_id_name_idx
    ON rhnUserGroup (org_id, id, name)
    TABLESPACE [[32m_tbs]]
    LOGGING;

CREATE INDEX rhn_ug_org_id_type_idx
    ON rhnUserGroup (group_type, id)
    TABLESPACE [[8m_tbs]]
    LOGGING;

CREATE INDEX rhn_ug_org_id_gtype_idx
    ON rhnUserGroup (org_id, group_type, id)
    TABLESPACE [[8m_tbs]];

