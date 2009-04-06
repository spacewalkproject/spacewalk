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


CREATE TABLE rhnSolarisPatchSetMembers
(
    patch_id      NUMBER NOT NULL 
                      CONSTRAINT rhn_solaris_psm_pid_fk
                          REFERENCES rhnPackage (id) 
                          ON DELETE CASCADE, 
    patch_set_id  NUMBER NOT NULL 
                      CONSTRAINT rhn_solaris_psm_psid_fk
                          REFERENCES rhnPackage (id) 
                          ON DELETE CASCADE, 
    patch_order   NUMBER, 
    created       DATE 
                      DEFAULT (sysdate) NOT NULL, 
    modified      DATE 
                      DEFAULT (sysdate) NOT NULL
)
TABLESPACE [[8m_data_tbs]]
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_solaris_psm_pid_psid_idx
    ON rhnSolarisPatchSetMembers (patch_id, patch_set_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_solaris_psm_psid_pid_idx
    ON rhnSolarisPatchSetMembers (patch_set_id, patch_id)
    TABLESPACE [[4m_tbs]];

