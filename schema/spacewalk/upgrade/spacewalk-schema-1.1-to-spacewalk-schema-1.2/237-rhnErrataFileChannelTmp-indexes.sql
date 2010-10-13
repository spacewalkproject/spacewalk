CREATE INDEX rhn_efilectmp_cid_idx
    ON rhnErrataFileChannelTmp (channel_id)
    TABLESPACE [[64k_tbs]];

DROP INDEX rhn_efilec_cid_efid_idx;
