-- created by Oraschemadoc Fri Jan 22 13:40:45 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM_H1"."RHNSERVEROUTDATEDPACKAGES" ("SERVER_ID", "PACKAGE_NAME_ID", "PACKAGE_EVR_ID", "PACKAGE_NVRE", "ERRATA_ID", "ERRATA_ADVISORY") AS 
  SELECT DISTINCT SNPC.server_id,
       P.name_id,
       P.evr_id,
       PN.name || '-' || evr_t_as_vre_simple( PE.evr ),
       E.id,
       E.advisory
  FROM rhnPackageName PN,
       rhnPackageEVR PE,
       rhnPackage P,
       rhnServerNeededPackageCache SNPC
         left outer join
        rhnErrata E
          on SNPC.errata_id = E.id
 WHERE SNPC.package_id = P.id
   AND P.name_id = PN.id
   AND P.evr_id = PE.id
 
/
