--
-- Copyright (c) 2008 Red Hat, Inc.
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
-- $Id$
--

create or replace view rhnUserServerPermsDupes as
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

--
-- $Log$
-- Revision 1.7  2004/06/23 23:04:33  pjones
-- bugzilla: 125937 -- make rhnUserServerPermsDupes about 35% faster.
--
