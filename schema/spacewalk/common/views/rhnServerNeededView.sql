--
-- Copyright (c) 2010 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--


-- A view that displays packages which can be updated on selected client.
-- This is an uncached version of rhnServerNeededCache.

create or replace view
rhnServerNeededView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id,
    channel_id
)
as
select s.org_id,
       s.id as server_id,
       pce.errata_id,
       pkg.id as package_id,
       neededpkg.name_id as package_name_id,
       scp.min_channel_id as channel_id
  from (select sc.server_id, np.name_id, np.package_arch_id, max(np.evr) max_evr
          from (-- list of newest packages in channels with EVR
                select np_np.*, np_pe.evr
                  from rhnchannelnewestpackage np_np
                  join rhnpackageEVR np_pe
                    on np_pe.id = np_np.evr_id) np
          join (-- list of packages on the server with EVR
                select sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id, max(sp_pe.evr) as max_evr
                  from rhnserverpackage sp_sp
                  join rhnpackageEVR sp_pe
                    on sp_pe.id = sp_sp.evr_id
                 group by sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id) sp
            on -- at first - we want only newer (=higher EVR) packages than there are on the server
               sp.name_id = np.name_id and sp.max_evr < np.evr
          join -- secondly - packages must be upgrade compatible
               rhnpackageupgradearchcompat puac
            on puac.package_arch_id = sp.package_arch_id and puac.package_upgrade_arch_id = np.package_arch_id
          join -- thirdly - packages must be in channel where server is subscribed to
               rhnserverchannel sc
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
          join rhnpackageevr p_evr
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
;
