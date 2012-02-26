
CREATE TABLE rhnXccdfRuleresultType
(
    id            NUMBER NOT NULL
                      CONSTRAINT rhn_xccdf_rresult_t_id_pk PRIMARY KEY
                      USING INDEX TABLESPACE [[64k_tbs]],
    abbreviation  CHAR(1) NOT NULL,
    label         VARCHAR2(16) NOT NULL,
    description   VARCHAR2(120) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_xccdf_rresult_t_label_uq
    ON rhnXccdfRuleresultType (label)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;
