CREATE INDEX rhn_sc_cid_idx
    ON rhnServerChannel (channel_id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;
drop index rhn_sc_cid_sid_idx;
