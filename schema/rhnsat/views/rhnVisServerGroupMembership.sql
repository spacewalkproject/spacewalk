CREATE OR REPLACE VIEW rhnVisServerGroupMembership (
         ORG_ID, SERVER_ID, GROUP_ID, GROUP_NAME, GROUP_TYPE, CURRENT_MEMBERS, MAX_MEMBERS
)
AS
SELECT   SG.org_id, SGM.server_id, SG.id, SG.name, SGT.label, SG.current_members, SG.max_members
  FROM   rhnServerGroupType SGT, 
	 rhnServerGroupMembers SGM,
    	 rhnVisibleServerGroup SG
 WHERE   SG.id = SGM.server_group_id(+)
   AND   SG.group_type = SGT.id(+)
/
