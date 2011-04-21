-- created by Oraschemadoc Thu Apr 21 10:04:14 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNSERVERNEEDEDVIEW" ("ORG_ID", "SERVER_ID", "ERRATA_ID", "PACKAGE_ID", "PACKAGE_NAME_ID", "CHANNEL_ID") AS 
  select s.org_id,
       s.id as server_id,
       pce.errata_id,
       pkg.id as package_id,
       neededpkg.name_id as package_name_id,
       scp.min_channel_id as channel_id
  from (select sc.server_id, np.name_id, np.package_arch_id, max(np.evr) max_evr
          from (-- list of newest packages in channels with EVR
                select np_np.*, np_pe.evr
                  from rhnChannelNewestPackage np_np
                  join rhnPackageEVR np_pe
                    on np_pe.id = np_np.evr_id) np
          join (-- list of packages on the server with EVR
                select sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id, max(sp_pe.evr) as max_evr
                  from rhnServerPackage sp_sp
                  join rhnPackageEVR sp_pe
                    on sp_pe.id = sp_sp.evr_id
                 group by sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id) sp
            on -- at first - we want only newer (=higher EVR) packages than there are on the server
               sp.name_id = np.name_id and sp.max_evr < np.evr
          join -- secondly - packages must be upgrade compatible
               rhnPackageUpgradeArchCompat puac
            on puac.package_arch_id = sp.package_arch_id and puac.package_upgrade_arch_id = np.package_arch_id
          join -- thirdly - packages must be in channel where server is subscribed to
               rhnServerChannel sc
            on sc.server_id = sp.server_id and sc.channel_id = np.channel_id
        group by sc.server_id, np.name_id, np.package_arch_id
        ) neededpkg
  join -- lookup org_id by server
       rhnServer s
    on neededpkg.server_id = s.id
  join (--lookup package_id by max_evr, name and package_arch
        select p.*, p_evr.evr
               --
               , p_evr.release, p_evr.version, p_evr.epoch
          from rhnPackage p
          join rhnPackageEVR p_evr
            on p_evr.id = p.evr_id) pkg
    on pkg.evr = neededpkg.max_evr
   and pkg.name_id = neededpkg.name_id
   and pkg.package_arch_id = neededpkg.package_arch_id
  join (-- lookup channel_id - we want only one id eve if package is in more channels
        -- so pick lowest one
        select cp.package_id, csc.server_id, min(cp.channel_id) as min_channel_id
          from rhnChannelPackage cp
          join rhnServerChannel csc
            on csc.channel_id = cp.channel_id
         group by cp.package_id, csc.server_id) scp
    on scp.package_id = pkg.id and scp.server_id = neededpkg.server_id
  left join (-- lookup errata id (can be NULL)
             select ep.package_id, ce.errata_id, ce.channel_id
               from rhnErrataPackage ep
               join rhnChannelErrata ce
                 on ce.errata_id = ep.errata_id) pce
    on pce.package_id = pkg.id and pce.channel_id = scp.min_channel_id

 
/
