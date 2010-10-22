CREATE INDEX rhn_err_pkg_pid_idx
    ON rhnErrataPackage (package_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;
drop index rhn_err_pkg_pid_eid_idx;
