-- created by Oraschemadoc Fri Jan 22 13:40:46 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNUSERGROUPMEMBERSHIP" ("ORG_ID", "USER_ID", "GROUP_ID", "GROUP_NAME", "GROUP_TYPE") AS
  SELECT   UG.org_id, UGM.user_id, UG.id, UG.name, UGT.label
  FROM   rhnUserGroupType UGT,
    	 rhnUserGroup UG
	    left outer join
	 rhnUserGroupMembers UGM on(UG.id = UGM.user_group_id)
 WHERE   UG.group_type = UGT.id

 
/
