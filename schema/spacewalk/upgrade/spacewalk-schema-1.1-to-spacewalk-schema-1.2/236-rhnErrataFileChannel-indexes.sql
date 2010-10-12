CREATE INDEX rhn_efilec_cid_idx
    ON rhnErrataFileChannel (channel_id)
    TABLESPACE [[64k_tbs]];

DROP INDEX rhn_efilec_cid_efid_idx;
