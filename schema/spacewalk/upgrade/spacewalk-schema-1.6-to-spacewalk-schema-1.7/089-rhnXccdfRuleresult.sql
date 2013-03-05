
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
