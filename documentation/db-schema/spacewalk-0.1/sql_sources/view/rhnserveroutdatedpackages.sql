-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNSERVEROUTDATEDPACKAGES" ("SERVER_ID", "PACKAGE_NAME_ID", "PACKAGE_EVR_ID", "PACKAGE_NVRE", "ERRATA_ID", "ERRATA_ADVISORY") AS 
  SELECT DISTINCT SNPC.server_id,
       P.name_id,
       P.evr_id,
       PN.name || '-' || PE.evr.as_vre_simple(),
       E.id,
       E.advisory
  FROM rhnErrata E,
       rhnPackageName PN,
       rhnPackageEVR PE,
       rhnPackage P,
       rhnServerNeededPackageCache SNPC
 WHERE SNPC.package_id = P.id
   AND P.name_id = PN.id
   AND P.evr_id = PE.id
   AND SNPC.errata_id = E.id(+)
 
/
