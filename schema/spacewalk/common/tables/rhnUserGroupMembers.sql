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


CREATE TABLE rhnUserGroupMembers
(
    user_id        NUMBER NOT NULL 
                       CONSTRAINT rhn_ugmembers_uid_fk
                           REFERENCES web_contact (id) 
                           ON DELETE CASCADE, 
    user_group_id  NUMBER NOT NULL 
                       CONSTRAINT rhn_ugmembers_ugid_fk
                           REFERENCES rhnUserGroup (id), 
    created        DATE 
                       DEFAULT (sysdate) NOT NULL, 
    modified       DATE 
                       DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_ugmembers_uid_ugid_uq
    ON rhnUserGroupMembers (user_id, user_group_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_ugmembers_ugid_uid_idx
    ON rhnUserGroupMembers (user_group_id, user_id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;

