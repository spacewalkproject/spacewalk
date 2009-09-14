-- created by Oraschemadoc Mon Aug 31 10:54:33 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNSERVERNEEDEDPACKAGECACHE" ("SERVER_ID", "PACKAGE_ID", "ERRATA_ID") AS 
  select
	server_id,
	package_id,
	max(errata_id) as errata_id
	from rhnServerNeededCache
	group by server_id, package_id
 
/
