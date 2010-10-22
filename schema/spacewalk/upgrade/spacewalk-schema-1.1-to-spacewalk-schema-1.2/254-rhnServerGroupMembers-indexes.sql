CREATE INDEX rhn_sgmembers_sgid_idx
    ON rhnServerGroupMembers (server_group_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;
drop index rhn_sgmembers_sgid_sid_idx;
