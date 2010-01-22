-- created by Oraschemadoc Fri Jan 22 13:40:48 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM_H1"."RHNVISSERVERGROUPOVERVIEWLITE" ("ORG_ID", "SECURITY_ERRATA", "BUG_ERRATA", "ENHANCEMENT_ERRATA", "GROUP_ID", "GROUP_NAME", "GROUP_ADMINS", "SERVER_COUNT", "NOTE_COUNT", "MODIFIED", "MAX_MEMBERS") AS 
  select	sg.org_id					org_id,
		case when exists (
			select	1
			from	rhnServerGroupOVLiteHelper
			where	server_group_id = sg.id
				and advisory_type = 'Security Advisory'
			)
			then 1
			else 0
			end						security_errata,
		case when exists (
			select	1
			from	rhnServerGroupOVLiteHelper
			where	server_group_id = sg.id
				and advisory_type = 'Bug Fix Advisory'
			)
			then 1
			else 0
			end						bug_errata,
		case when exists (
			select	1
			from	rhnServerGroupOVLiteHelper
			where	server_group_id = sg.id
				and advisory_type = 'Product Enhancement Advisory'
			)
			then 1
			else 0
			end						enhancement_errata,
		sg.id						group_id,
		sg.name						group_name,
		(	select	count(*)
			from	rhnUserManagedServerGroups	umsg
			where	umsg.server_group_id = sg.id
		)							group_admins,
		(	select	count(*)
			from	rhnServerGroupMembers		sgm
			where	sgm.server_group_id = sg.id
		)							server_count,
		0							note_count,
		sysdate						modified,
		max_members					max_members
from	rhnVisibleServerGroup		sg
 
/
