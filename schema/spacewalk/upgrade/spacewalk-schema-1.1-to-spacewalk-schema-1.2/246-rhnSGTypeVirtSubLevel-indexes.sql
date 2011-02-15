CREATE INDEX rhn_sgtvsl_vslid
    ON rhnSGTypeVirtSubLevel (virt_sub_level_id)
    TABLESPACE [[64k_tbs]];
drop index rhn_sgtvsl_vslid_sgtid;
