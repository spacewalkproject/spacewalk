-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNSERVERGROUPOVLITEHELPER" ("SERVER_GROUP_ID", "ADVISORY_TYPE") AS 
  select	sgm.server_group_id						server_group_id,
		e.advisory_type							advisory_type
from	rhnErrata								e,
		rhnServerNeededPackageCache				snpc,
		rhnServerGroupMembers					sgm
where   1=1
	and sgm.server_id = snpc.server_id
	and snpc.errata_id = e.id
 
/
