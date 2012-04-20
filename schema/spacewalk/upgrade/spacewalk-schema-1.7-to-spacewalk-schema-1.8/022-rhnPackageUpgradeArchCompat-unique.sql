
drop index rhn_puac_pa_pua;
create unique index rhn_puac_pa_pua_uq
     on rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id);

