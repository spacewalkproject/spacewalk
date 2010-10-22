CREATE INDEX rhn_ugmembers_ugid_idx
    ON rhnUserGroupMembers (user_group_id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;
drop index rhn_ugmembers_ugid_uid_idx;
