--
-- Copyright (c) 2008 Red Hat, Inc.
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


-- A view that displays an uncached version of rhnServerNeededCache

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
SELECT DISTINCT S.org_id,
     S.id as server_id,
     ep.errata_id as errata_id,
     P.id as package_id,
     P.name_id as package_name_id,
     CP.channel_id as channel_id
FROM
    rhnPackage P
    inner join rhnPackageEVR P_EVR on P_EVR.id = P.evr_id
    inner join rhnPackageEVR SP_EVR on SP_EVR.evr < P_EVR.evr  
    inner join rhnServerPackage SP on SP.name_id = P.name_id 
               and SP.evr_id = SP_EVR.id
               AND SP.evr_id != P.evr_id
    inner join rhnServer S on SP.server_id = S.id
    inner join rhnServerPackageArchCompat SPAC on spac.server_arch_id = s.server_arch_id 
               AND p.package_arch_id = spac.package_arch_id
    inner join rhnServerChannel SC on SC.server_id = S.id 
    inner join rhnChannelPackage CP on CP.package_id = P.id 
               and SC.channel_id = CP.channel_id
    left outer join rhnErrataPackage EP on EP.package_id = P.id
                   AND EXISTS 
                   (SELECT 1 from rhnChannelErrata CE where ce.channel_id = SC.channel_id
                    AND CE.errata_id = EP.errata_id) 
    where
           --- If the channel has more than 1 package with the same NVRE but different arches
           ---  Then we need to add an additional join condition (the server's package arch id) 
           P.package_arch_id = COALESCE(
                                   (select distinct 1
                                       from rhnPackage P2 inner join rhnChannelPackage CP2
                                            on P2.id = CP2.package_id
                                         where CP2.channel_id = SC.channel_id and
                                               P2.id = CP2.package_id and
                                               P2.name_id = P.name_id
                                          group by P2.evr_id having count(*) > 1),
                                    COALESCE(SP.package_arch_id, P.package_arch_id),
                                    P.package_arch_id
                               )
           AND
           ---  If we can use arch to find the MAX EVR, use that 
           ---  Otherwise just use whatever they have 
           SP_EVR.evr =
                  COALESCE(
                     (SELECT MAX(PE.evr) FROM rhnServerPackage SP2, rhnPackageEvr PE
                       WHERE PE.id = SP2.evr_id AND SP2.server_id = SP.server_id AND
                         SP2.name_id = SP.name_id
                         AND COALESCE(SP2.package_arch_id, P.package_arch_id) = P.package_arch_id
                     ),
                     (SELECT MAX(PE.evr) FROM rhnServerPackage SP2, rhnPackageEvr PE
                       WHERE PE.id = SP2.evr_id AND SP2.server_id = SP.server_id AND
                      SP2.name_id = SP.name_id)
                    )
;
