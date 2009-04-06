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


CREATE TABLE rhnUserServerPerms
(
    user_id    NUMBER NOT NULL 
                   CONSTRAINT rhn_usperms_uid_fk
                       REFERENCES web_contact (id), 
    server_id  NUMBER NOT NULL 
                   CONSTRAINT rhn_usperms_sid_fk
                       REFERENCES rhnServer (id)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_usperms_uid_sid_uq
    ON rhnUserServerPerms (user_id, server_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_usperms_sid_idx
    ON rhnUserServerPerms (server_id)
    TABLESPACE [[4m_tbs]];

