CREATE INDEX rhn_cfvsl_vslid_idx
    ON rhnChannelFamilyVirtSubLevel (virt_sub_level_id)
    TABLESPACE [[64k_tbs]];

DROP INDEX rhn_cfvsl_vslid_cfid_idx;
