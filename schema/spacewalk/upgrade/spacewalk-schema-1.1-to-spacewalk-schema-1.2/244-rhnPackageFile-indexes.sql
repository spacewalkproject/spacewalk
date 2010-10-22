CREATE INDEX rhn_package_file_cid_idx
    ON rhnPackageFile (capability_id)
    TABLESPACE [[32m_tbs]]
    NOLOGGING;
drop index rhn_package_file_cid_pid_idx;
