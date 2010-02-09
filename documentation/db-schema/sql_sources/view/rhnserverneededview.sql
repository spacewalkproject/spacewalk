-- created by Oraschemadoc Fri Jan 22 13:40:45 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNSERVERNEEDEDVIEW" ("ORG_ID", "SERVER_ID", "ERRATA_ID", "PACKAGE_ID", "PACKAGE_NAME_ID", "CHANNEL_ID") AS
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
    where SP_EVR.evr = (SELECT MAX(PE.evr) FROM rhnServerPackage SP2, rhnPackageEvr PE
                       WHERE PE.id = SP2.evr_id AND SP2.server_id = SP.server_id AND
                        SP2.name_id = SP.name_id)
 
/
