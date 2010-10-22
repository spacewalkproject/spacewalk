CREATE INDEX rhn_udsg_sgid_idx
    ON rhnUserDefaultSystemGroups (system_group_id)
    TABLESPACE [[2m_tbs]];
drop index rhn_udsg_sgid_uid_idx;
