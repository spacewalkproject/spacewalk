-- created by Oraschemadoc Mon Aug 31 10:54:32 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNSERVERERRATATYPEVIEW" ("SERVER_ID", "ERRATA_ID", "ERRATA_TYPE") AS 
  SELECT
    	SNEC.server_id,
	SNEC.errata_id,
	E.advisory_type
FROM    rhnErrata E,
    	rhnServerNeededErrataCache SNEC
WHERE   E.id = SNEC.errata_id
GROUP BY SNEC.server_id, SNEC.errata_id, E.advisory_type

 
/
