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


CREATE TABLE rhnFileDownload
(
    file_id       NUMBER NOT NULL 
                      CONSTRAINT rhn_filedl_fid_fk
                          REFERENCES rhnFile (id), 
    location      VARCHAR2(2000) NOT NULL, 
    token         VARCHAR2(48), 
    requestor_ip  VARCHAR2(15) NOT NULL, 
    start_time    DATE 
                      DEFAULT (sysdate) NOT NULL, 
    user_id       NUMBER 
                      CONSTRAINT rhn_filedl_uid_fk
                          REFERENCES web_contact (id) 
                          ON DELETE SET NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_filedl_uid_fid_idx
    ON rhnFileDownload (user_id, file_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_filedl_token_idx
    ON rhnFileDownload (token)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_filedl_start_idx
    ON rhnFileDownload (start_time)
    TABLESPACE [[8m_tbs]];

