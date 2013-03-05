CREATE INDEX rhn_xccdf_rim_ident_idx
    ON rhnXccdfRuleIdentMap (ident_id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;
