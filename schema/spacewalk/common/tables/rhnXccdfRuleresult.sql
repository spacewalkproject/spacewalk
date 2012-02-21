--
-- Copyright (c) 2012 Red Hat, Inc.
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

CREATE TABLE rhnXccdfRuleresult
(
    testresult_id NUMBER NOT NULL
                      CONSTRAINT rhn_xccdf_rresult_tresult_fk
                          REFERENCES rhnXccdfTestresult (id)
                          ON DELETE CASCADE,
    ident_id      NUMBER NOT NULL
                      CONSTRAINT rhn_xccdf_rresult_ident_fk
                          REFERENCES rhnXccdfIdent (id),
    result_id     NUMBER NOT NULL
                      CONSTRAINT rhn_xccdf_rresult_result_fk
                          REFERENCES rhnXccdfRuleresultType (id)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_xccdf_rresult_tri_uq
    ON rhnXccdfRuleresult (testresult_id, ident_id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;
