DROP VIEW rhnServerGroupMembership;

CREATE OR REPLACE VIEW rhnServerGroupMembership (
         ORG_ID, SERVER_ID, GROUP_ID, GROUP_NAME, GROUP_TYPE, CURRENT_MEMBERS
)
AS
SELECT   SG.org_id, SGM.server_id, SG.id, SG.name, SGT.label, SG.current_members
  FROM
	 rhnServerGroupMembers SGM
             right join
    	 rhnServerGroup SG on (SG.id = SGM.server_group_id)
             left join
         rhnServerGroupType SGT on (SG.group_type = SGT.id)
;

DROP VIEW rhnVisServerGroupMembership;

CREATE OR REPLACE VIEW rhnVisServerGroupMembership (
         ORG_ID, SERVER_ID, GROUP_ID, GROUP_NAME, GROUP_TYPE, CURRENT_MEMBERS
)
AS
SELECT   SG.org_id, SGM.server_id, SG.id, SG.name, SGT.label, SG.current_members
  FROM
	 rhnServerGroupMembers SGM
            right outer join
    	 rhnVisibleServerGroup SG on (SG.id = SGM.server_group_id)
            left outer join
         rhnServerGroupType SGT on (SG.group_type = SGT.id)
;

DROP VIEW rhnVisServerGroupOverviewLite;

DROP VIEW rhnServerGroupOverview;

CREATE OR REPLACE VIEW rhnServerGroupOverview (
         ORG_ID, SECURITY_ERRATA, BUG_ERRATA, ENHANCEMENT_ERRATA, GROUP_ID, GROUP_NAME, GROUP_ADMINS, SERVER_COUNT, MODIFIED
)
AS
  SELECT SG.org_id,
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededErrataCache SNEC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Security Advisory'
                 and SNEC.errata_id = e.id
                 and SNEC.server_id = sgm.server_id
                 and sgm.server_group_id = sg.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededErrataCache SNEC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Bug Fix Advisory'
                 and SNEC.errata_id = e.id
                 and SNEC.server_id = sgm.server_id
                 and sgm.server_group_id = sg.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededErrataCache SNEC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Product Enhancement Advisory'
                 and SNEC.errata_id = e.id
                 and SNEC.server_id = sgm.server_id
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
         CURRENT_TIMESTAMP
    FROM rhnServerGroup SG;
