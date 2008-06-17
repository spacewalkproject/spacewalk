-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNUSERGROUPMEMBERSHIP" ("ORG_ID", "USER_ID", "GROUP_ID", "GROUP_NAME", "GROUP_TYPE") AS 
  SELECT   UG.org_id, UGM.user_id, UG.id, UG.name, UGT.label
  FROM   rhnUserGroupType UGT,
    	 rhnUserGroup UG,
	 rhnUserGroupMembers UGM
 WHERE   UG.id = UGM.user_group_id(+)
   AND   UG.group_type = UGT.id
 
/
