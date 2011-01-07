CREATE INDEX rhn_efilectmp_cid_idx
    ON rhnErrataFileChannelTmp (channel_id)
    TABLESPACE [[64k_tbs]];

alter table rhnErrataFileChannelTmp disable constraint RHN_EFILECTMP_EFID_CID_UQ;
DROP INDEX rhn_efilectmp_cid_efid_idx;
alter table rhnErrataFileChannelTmp enable constraint RHN_EFILECTMP_EFID_CID_UQ;
