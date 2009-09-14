-- created by Oraschemadoc Mon Aug 31 10:54:35 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNVISSERVERGROUPMEMBERSHIP" ("ORG_ID", "SERVER_ID", "GROUP_ID", "GROUP_NAME", "GROUP_TYPE", "CURRENT_MEMBERS", "MAX_MEMBERS") AS 
  SELECT   SG.org_id, SGM.server_id, SG.id, SG.name, SGT.label, SG.current_members, SG.max_members
  FROM
	 rhnServerGroupMembers SGM
            right outer join
    	 rhnVisibleServerGroup SG on (SG.id = SGM.server_group_id)
            left outer join
         rhnServerGroupType SGT on (SG.group_type = SGT.id)

 
/
