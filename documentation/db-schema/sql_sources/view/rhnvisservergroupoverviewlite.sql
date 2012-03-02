-- created by Oraschemadoc Fri Mar  2 05:58:03 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNVISSERVERGROUPOVERVIEWLITE" ("ORG_ID", "SECURITY_ERRATA", "BUG_ERRATA", "ENHANCEMENT_ERRATA", "GROUP_ID", "GROUP_NAME", "GROUP_ADMINS", "SERVER_COUNT", "MODIFIED", "MAX_MEMBERS") AS 
  select	sg.org_id					as org_id,
		case when exists (
			select	1
			from	rhnServerGroupOVLiteHelper
			where	server_group_id = sg.id
				and advisory_type = 'Security Advisory'
			)
			then 1
			else 0
			end						as security_errata,
		case when exists (
			select	1
			from	rhnServerGroupOVLiteHelper
			where	server_group_id = sg.id
				and advisory_type = 'Bug Fix Advisory'
			)
			then 1
			else 0
			end						as bug_errata,
		case when exists (
			select	1
			from	rhnServerGroupOVLiteHelper
			where	server_group_id = sg.id
				and advisory_type = 'Product Enhancement Advisory'
			)
			then 1
			else 0
			end						as enhancement_errata,
		sg.id						as group_id,
		sg.name						as group_name,
		(	select	count(*)
			from	rhnUserManagedServerGroups	umsg
			where	umsg.server_group_id = sg.id
		)							as group_admins,
		(	select	count(*)
			from	rhnServerGroupMembers		sgm
			where	sgm.server_group_id = sg.id
		)							as server_count,
		current_timestamp					as modified,
		max_members					as max_members
from	rhnVisibleServerGroup		sg

 
/
