--
-- $Id$
--
-- This is much more readable with tabsize as 4.  You've been warned ;)

create or replace view
rhnVisServerGroupOverviewLite as
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

-- $Log$
-- Revision 1.1  2002/11/11 23:37:43  pjones
-- add a Vis varient
--	
