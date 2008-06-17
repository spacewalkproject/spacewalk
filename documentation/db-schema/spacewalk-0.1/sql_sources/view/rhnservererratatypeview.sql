-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNSERVERERRATATYPEVIEW" ("SERVER_ID", "ERRATA_ID", "ERRATA_TYPE", "PACKAGE_COUNT") AS 
  SELECT
    	SNPC.server_id,
	SNPC.errata_id,
	E.advisory_type,
	COUNT(SNPC.package_id)
FROM    rhnErrata E,
    	rhnServerNeededPackageCache SNPC
WHERE   E.id = SNPC.errata_id
GROUP BY SNPC.server_id, SNPC.errata_id, E.advisory_type
 
/
