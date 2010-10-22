CREATE INDEX rhn_vi_vsid_idx
    ON rhnVirtualInstance (virtual_system_id)
    TABLESPACE [[64k_tbs]];
drop index rhn_vi_vsid_hsid_idx;
