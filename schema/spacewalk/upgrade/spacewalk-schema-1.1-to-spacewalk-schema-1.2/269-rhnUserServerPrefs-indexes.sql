drop index rhn_usprefs_n_sid_uid_idx;

CREATE INDEX rhn_usprefs_sid_idx
    ON rhnUserServerPrefs (server_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;
drop index rhn_usprefs_sid_uid_n_idx;
