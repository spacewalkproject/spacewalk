-- created by Oraschemadoc Fri Jan 22 13:40:44 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM_H1"."RHNSERVERGROUPOVERVIEW" ("ORG_ID", "SECURITY_ERRATA", "BUG_ERRATA", "ENHANCEMENT_ERRATA", "GROUP_ID", "GROUP_NAME", "GROUP_ADMINS", "SERVER_COUNT", "NOTE_COUNT", "MODIFIED", "MAX_MEMBERS") AS 
  SELECT SG.org_id,
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededPackageCache SNPC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Security Advisory'
                 and snpc.errata_id = e.id
                 and snpc.server_id = sgm.server_id
                 and sgm.server_group_id = sg.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededPackageCache SNPC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Bug Fix Advisory'
                 and snpc.errata_id = e.id
                 and snpc.server_id = sgm.server_id
                 and sgm.server_group_id = sg.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededPackageCache SNPC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Product Enhancement Advisory'
                 and snpc.errata_id = e.id
                 and snpc.server_id = sgm.server_id
                 and sgm.server_group_id = sg.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         SG.id, SG.name,
         (SELECT COUNT(*) FROM rhnUserManagedServerGroups UMSG WHERE UMSG.server_group_id = SG.id),
         (SELECT COUNT(*) FROM rhnServerGroupMembers SGM WHERE SGM.server_group_id = SG.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         0, SYSDATE, MAX_MEMBERS
    FROM rhnServerGroup SG
 
/
