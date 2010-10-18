CREATE INDEX rhn_efilectmp_cid_idx
    ON rhnErrataFileChannelTmp (channel_id)
    TABLESPACE [[64k_tbs]];

DROP INDEX rhn_efilectmp_cid_efid_idx;
