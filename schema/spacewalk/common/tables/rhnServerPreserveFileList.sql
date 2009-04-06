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


CREATE TABLE rhnServerPreserveFileList
(
    server_id     NUMBER NOT NULL 
                      CONSTRAINT rhn_serverpfl_ksid_fk
                          REFERENCES rhnServer (id), 
    file_list_id  NUMBER NOT NULL 
                      CONSTRAINT rhn_serverpfl_flid_fk
                          REFERENCES rhnFileList (id) 
                          ON DELETE CASCADE, 
    created       DATE 
                      DEFAULT (sysdate) NOT NULL, 
    modified      DATE 
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_serverpfl_ksid_flid_uq
    ON rhnServerPreserveFileList (server_id, file_list_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_serverpfl_flid_ksid_idx
    ON rhnServerPreserveFileList (file_list_id, server_id)
    TABLESPACE [[4m_tbs]];

