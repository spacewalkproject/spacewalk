CREATE INDEX rhn_cfperm_cfid_idx
    ON rhnPrivateChannelFamily (channel_family_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;
drop index rhn_cfperm_cfid_oid_idx;
