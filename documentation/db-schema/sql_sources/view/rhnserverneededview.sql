-- created by Oraschemadoc Fri Mar  2 05:58:01 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNSERVERNEEDEDVIEW" ("ORG_ID", "SERVER_ID", "ERRATA_ID", "PACKAGE_ID", "PACKAGE_NAME_ID", "CHANNEL_ID") AS 
  SELECT s.org_id,
       sp.server_id,
       x.errata_id,
       up.id,
       up.name_id,
       x.channel_id
    FROM rhnServer s
        join (SELECT sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id, max(sp_pe.evr) AS max_evr
                FROM rhnServerPackage sp_sp
                    join rhnPackageEvr sp_pe ON sp_pe.id = sp_sp.evr_id
                    GROUP BY sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id) sp ON sp.server_id = s.id
        join rhnPackage up ON up.name_id = sp.name_id
        join rhnPackageEvr upe ON upe.id = up.evr_id AND sp.max_evr < upe.evr
        join rhnPackageUpgradeArchCompat puac ON puac.package_arch_id = sp.package_arch_id AND puac.package_upgrade_arch_id = up.package_arch_id
        join rhnServerChannel sc ON sc.server_id = sp.server_id
        join rhnChannelPackage cp ON cp.package_id = up.id AND cp.channel_id = sc.channel_id
        left join
        (SELECT ep.errata_id, cp.channel_id, ep.package_id
         FROM rhnChannelErrata cp
             join rhnErrataPackage ep ON ep.errata_id = cp.errata_id) x
            ON x.channel_id = sc.channel_id AND x.package_id = cp.package_id

 
/
