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


CREATE TABLE rhnServerUuid
(
    server_id  NUMBER NOT NULL 
                   CONSTRAINT rhn_server_uuid_sid_fk
                       REFERENCES rhnServer (id), 
    uuid       VARCHAR2(36) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_server_uuid_sid_unq
    ON rhnServerUuid (server_id)
    TABLESPACE [[4m_tbs]];

CREATE UNIQUE INDEX rhn_serveruuid_uuid_sid_unq
    ON rhnServerUUID (uuid, server_id)
    TABLESPACE [[4m_tbs]];

