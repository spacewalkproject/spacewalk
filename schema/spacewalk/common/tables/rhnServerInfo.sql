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


CREATE TABLE rhnServerInfo
(
    server_id        NUMBER NOT NULL 
                         CONSTRAINT rhn_server_info_sid_fk
                             REFERENCES rhnServer (id), 
    checkin          DATE 
                         DEFAULT (sysdate), 
    checkin_counter  NUMBER 
                         DEFAULT (0)
)
ENABLE ROW MOVEMENT
LOGGING
;

CREATE UNIQUE INDEX rhn_server_info_sid_unq
    ON rhnServerInfo (server_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;

