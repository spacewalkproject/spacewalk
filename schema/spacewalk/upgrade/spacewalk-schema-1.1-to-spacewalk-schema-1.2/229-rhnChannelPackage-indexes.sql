CREATE INDEX rhn_cp_pid_idx
    ON rhnChannelPackage (package_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

DROP INDEX rhn_cp_pc_idx;
