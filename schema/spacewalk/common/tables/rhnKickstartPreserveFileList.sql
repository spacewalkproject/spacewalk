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


CREATE TABLE rhnKickstartPreserveFileList
(
    kickstart_id  NUMBER NOT NULL 
                      CONSTRAINT rhn_kspreservefl_ksid_fk
                          REFERENCES rhnKSData (id) 
                          ON DELETE CASCADE, 
    file_list_id  NUMBER NOT NULL 
                      CONSTRAINT rhn_kspreservefl_flid_fk
                          REFERENCES rhnFileList (id) 
                          ON DELETE CASCADE, 
    created       DATE 
                      DEFAULT (sysdate) NOT NULL, 
    modified      DATE 
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_kspreservefl_ksid_flid_uq
    ON rhnKickstartPreserveFileList (kickstart_id, file_list_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_kspreservefl_flid_ksid_idx
    ON rhnKickstartPreserveFileList (file_list_id, kickstart_id)
    TABLESPACE [[8m_tbs]];

