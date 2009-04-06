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


CREATE TABLE rhnServerLock
(
    server_id  NUMBER NOT NULL 
                   CONSTRAINT rhn_server_lock_sid_fk
                       REFERENCES rhnServer (id), 
    locker_id  NUMBER 
                   CONSTRAINT rhn_server_lock_lid_fk
                       REFERENCES web_contact (id) 
                       ON DELETE SET NULL, 
    reason     VARCHAR2(4000), 
    created    DATE 
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_server_lock_sid_unq
    ON rhnServerLock (server_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_server_lock_lid_unq
    ON rhnServerLock (locker_id)
    TABLESPACE [[4m_tbs]];

