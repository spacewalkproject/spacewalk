-- created by Oraschemadoc Fri Jan 22 13:40:44 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNSERVERGROUPMEMBERSHIP" ("ORG_ID", "SERVER_ID", "GROUP_ID", "GROUP_NAME", "GROUP_TYPE", "CURRENT_MEMBERS", "MAX_MEMBERS") AS
  SELECT   SG.org_id, SGM.server_id, SG.id, SG.name, SGT.label, SG.current_members, SG.max_members
  FROM
	 rhnServerGroupMembers SGM
             right join
    	 rhnServerGroup SG on (SG.id = SGM.server_group_id)
             left join
         rhnServerGroupType SGT on (SG.group_type = SGT.id)

 
/
