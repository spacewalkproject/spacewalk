
DROP INDEX rhn_cs_repo_uq;

CREATE UNIQUE INDEX rhn_cs_repo_uq
    ON rhnContentSource(org_id, type_id, source_url, 
                            (case when label like 'manifest_%' then 1 else 0 end))
        tablespace [[64k_tbs]];

