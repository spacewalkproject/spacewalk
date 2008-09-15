-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNUSERSINORGOVERVIEW" ("ORG_ID", "USER_ID", "USER_LOGIN", "USER_FIRST_NAME", "USER_LAST_NAME", "USER_MODIFIED", "SERVER_COUNT", "SERVER_GROUP_COUNT", "ROLE_NAMES") AS 
  select
	u.org_id					org_id,
	u.id						user_id,
	u.login						user_login,
	pi.first_names					user_first_name,
	pi.last_name					user_last_name,
	u.modified					user_modified,
    	(	select	count(server_id)
		from	rhnUserServerPerms sp
		where	sp.user_id = u.id)
							server_count,
	(	select	count(server_group_id)
		from	rhnUserManagedServerGroups umsg
		where	umsg.user_id = u.id and exists (
			select	1
			from	rhnVisibleServerGroup sg
			where	sg.id = umsg.server_group_id))
							server_group_count,
	(	select	nvl(utcv.names, '(normal user)')
		from	rhnUserTypeCommaView utcv
		where	utcv.user_id = u.id)
							role_names
from	web_user_personal_info pi,
	web_contact u
where
	u.id = pi.web_user_id
 
/
