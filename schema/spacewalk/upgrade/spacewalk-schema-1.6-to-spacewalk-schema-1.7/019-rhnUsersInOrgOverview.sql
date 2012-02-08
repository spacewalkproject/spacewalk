--
-- Copyright (c) 2008--2012 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
drop view rhnUsersInOrgOverview;
create view rhnUsersInOrgOverview as
select    
	u.org_id					as org_id,
	u.id						as user_id,
	u.login						as user_login,
	pi.first_names					as user_first_name,
	pi.last_name					as user_last_name,
	u.modified					as user_modified,
    	(	select	count(server_id)
		from	rhnUserServerPerms sp
		where	sp.user_id = u.id)
							as server_count,
	(	select	count(server_group_id)
		from	rhnUserManagedServerGroups umsg
		where	umsg.user_id = u.id and exists (
			select	1
			from	rhnVisibleServerGroup sg
			where	sg.id = umsg.server_group_id))
							as server_group_count,
	coalesce(rhn_user.role_names(u.id), '(normal user)') as role_names
from	web_user_personal_info pi, 
	web_contact u 
where
	u.id = pi.web_user_id;

