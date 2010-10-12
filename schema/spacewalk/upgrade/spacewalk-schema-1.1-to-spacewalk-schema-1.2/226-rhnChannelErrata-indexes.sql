CREATE INDEX rhn_ce_eid_idx
    ON rhnChannelErrata (errata_id)
    TABLESPACE [[64k_tbs]];

DROP INDEX rhn_ce_eid_cid_idx;
