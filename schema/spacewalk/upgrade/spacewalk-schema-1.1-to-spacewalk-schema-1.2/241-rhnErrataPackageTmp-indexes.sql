CREATE INDEX rhn_err_pkgtmp_pid_idx
    ON rhnErrataPackageTmp (package_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;
drop index rhn_err_pkgtmp_pid_eid_idx;
