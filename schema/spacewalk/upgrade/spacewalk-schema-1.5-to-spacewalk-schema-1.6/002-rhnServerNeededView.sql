CREATE OR REPLACE VIEW
rhnServerNeededView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id,
    channel_id
)
AS
SELECT s.org_id,
       sp.server_id,
       x.errata_id,
       up.id,
       up.name_id,
       x.channel_id
    FROM rhnServer s
        join rhnServerPackage sp ON sp.server_id = s.id
        join rhnPackageEvr pe ON pe.id = sp.evr_id
        join rhnPackage up ON up.name_id = sp.name_id
        join rhnPackageEvr upe ON upe.id = up.evr_id AND pe.evr < upe.evr
        join rhnPackageUpgradeArchCompat puac ON puac.package_arch_id = sp.package_arch_id AND puac.package_upgrade_arch_id = up.package_arch_id
        join rhnServerChannel sc ON sc.server_id = sp.server_id
        join rhnChannelPackage cp ON cp.package_id = up.id AND cp.channel_id = sc.channel_id
        left join
        (SELECT ep.errata_id, cp.channel_id, ep.package_id
         FROM rhnChannelErrata cp
             join rhnErrataPackage ep ON ep.errata_id = cp.errata_id) x
            ON x.channel_id = sc.channel_id AND x.package_id = cp.package_id
;
