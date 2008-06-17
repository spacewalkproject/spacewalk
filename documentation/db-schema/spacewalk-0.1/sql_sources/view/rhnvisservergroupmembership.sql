-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNVISSERVERGROUPMEMBERSHIP" ("ORG_ID", "SERVER_ID", "GROUP_ID", "GROUP_NAME", "GROUP_TYPE", "CURRENT_MEMBERS", "MAX_MEMBERS") AS 
  SELECT   SG.org_id, SGM.server_id, SG.id, SG.name, SGT.label, SG.current_members, SG.max_members
  FROM   rhnServerGroupType SGT,
	 rhnServerGroupMembers SGM,
    	 rhnVisibleServerGroup SG
 WHERE   SG.id = SGM.server_group_id(+)
   AND   SG.group_type = SGT.id(+)
 
/
