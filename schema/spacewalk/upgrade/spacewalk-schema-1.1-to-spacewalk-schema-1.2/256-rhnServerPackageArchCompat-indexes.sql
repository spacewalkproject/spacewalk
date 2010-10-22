CREATE INDEX rhn_sp_ac_paid_pref
    ON rhnServerPackageArchCompat (package_arch_id)
    TABLESPACE [[64k_tbs]];
drop index rhn_sp_ac_paid_said_pref;
