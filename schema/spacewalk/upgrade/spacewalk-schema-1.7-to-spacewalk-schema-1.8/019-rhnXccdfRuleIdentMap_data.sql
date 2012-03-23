
INSERT INTO rhnXccdfRuleIdentMap
    (rresult_id, ident_id)
    SELECT xrr.id, xrr.ident_id
        FROM rhnXccdfRuleresult xrr;

COMMIT;
