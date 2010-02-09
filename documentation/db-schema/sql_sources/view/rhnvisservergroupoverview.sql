-- created by Oraschemadoc Fri Jan 22 13:40:48 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNVISSERVERGROUPOVERVIEW" ("ORG_ID", "SECURITY_ERRATA", "BUG_ERRATA", "ENHANCEMENT_ERRATA", "GROUP_ID", "GROUP_NAME", "GROUP_ADMINS", "SERVER_COUNT", "NOTE_COUNT", "MODIFIED", "MAX_MEMBERS") AS
  SELECT SG.org_id,
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Security Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Bug Fix Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Product Enhancement Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
	 SG.id, SG.name,
	 (SELECT COUNT(*) FROM rhnUserManagedServerGroups UMSG WHERE UMSG.server_group_id = SG.id),
	 (SELECT COUNT(*) FROM rhnServerGroupMembers SGM WHERE SGM.server_group_id = SG.id),
	 0, SYSDATE, MAX_MEMBERS
    FROM rhnVisibleServerGroup SG
 
/
