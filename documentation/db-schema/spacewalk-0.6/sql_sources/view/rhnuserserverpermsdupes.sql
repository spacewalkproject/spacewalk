-- created by Oraschemadoc Mon Aug 31 10:54:34 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNUSERSERVERPERMSDUPES" ("USER_ID", "SERVER_ID") AS 
  select	usg.user_id,
	sgm.server_id
from	rhnServerGroupMembers sgm,
	rhnUserServerGroupPerms usg
where	usg.server_group_id = sgm.server_group_id
union all
select	ugm.user_id, s.id
from	rhnServer s,
	rhnUserGroup ug,
	rhnUserGroupMembers ugm,
	rhnUserGroupType ugt
where	ugt.label = 'org_admin'
	and ugm.user_group_id = ug.id
	and ug.group_type = ugt.id
	and ug.org_id = s.org_id
 
/
