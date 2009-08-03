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


CREATE TABLE rhnUserDefaultSystemGroups
(
    user_id          NUMBER NOT NULL
                         CONSTRAINT rhn_udsg_uid_fk
                             REFERENCES web_contact (id)
                             ON DELETE CASCADE,
    system_group_id  NUMBER NOT NULL
                         CONSTRAINT rhn_udsg_cidffk
                             REFERENCES rhnServerGroup (id)
                             ON DELETE CASCADE
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_udsg_uid_sgid_idx
    ON rhnUserDefaultSystemGroups (user_id, system_group_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_udsg_sgid_uid_idx
    ON rhnUserDefaultSystemGroups (system_group_id, user_id)
    TABLESPACE [[2m_tbs]];

