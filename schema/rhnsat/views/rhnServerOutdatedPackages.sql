
CREATE OR REPLACE VIEW
rhnServerOutdatedPackages
(
    server_id,
    package_name_id,
    package_evr_id,    
    package_nvre,
    errata_id,
    errata_advisory
)
AS
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
