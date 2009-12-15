-- created by Oraschemadoc Mon Aug 31 10:54:33 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNSERVERGROUPOVLITEHELPER" ("SERVER_GROUP_ID", "ADVISORY_TYPE") AS 
  select	sgm.server_group_id						as server_group_id,
		e.advisory_type							as advisory_type
from	rhnErrata								e,
		rhnServerNeededPackageCache				snpc,
		rhnServerGroupMembers					sgm
where   sgm.server_id = snpc.server_id
	and snpc.errata_id = e.id

 
/
