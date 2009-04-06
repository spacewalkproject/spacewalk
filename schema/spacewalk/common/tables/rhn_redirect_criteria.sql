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


CREATE TABLE rhn_redirect_criteria
(
    recid        NUMBER NOT NULL 
                     CONSTRAINT rhn_rdrcr_recid_pk PRIMARY KEY 
                     USING INDEX TABLESPACE [[4m_tbs]], 
    redirect_id  NUMBER NOT NULL, 
    match_param  VARCHAR2(255) NOT NULL, 
    match_value  VARCHAR2(255), 
    inverted     CHAR(1) 
                     DEFAULT (0) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_redirect_criteria IS 'rdrcr  redirect criteria';

CREATE INDEX rhn_rdrcr_redirect_id_idx
    ON rhn_redirect_criteria (redirect_id)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_redirect_crit_recid_seq;

ALTER TABLE rhn_redirect_criteria
    ADD CONSTRAINT rhn_rdrcr_rdrct_redirect_id_fk FOREIGN KEY (redirect_id)
    REFERENCES rhn_redirects (recid) 
        ON DELETE CASCADE;

ALTER TABLE rhn_redirect_criteria
    ADD CONSTRAINT rhn_rdrcr_rdrmt_match_nm_fk FOREIGN KEY (match_param)
    REFERENCES rhn_redirect_match_types (name);

