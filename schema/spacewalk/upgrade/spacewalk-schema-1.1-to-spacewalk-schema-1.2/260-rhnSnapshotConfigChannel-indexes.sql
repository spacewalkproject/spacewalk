CREATE INDEX rhn_snpsht_cc_ccid_idx
    ON rhnSnapshotConfigChannel (config_channel_id)
    TABLESPACE [[4m_tbs]];
drop index rhn_snpsht_cc_ccid_sid_idx;
