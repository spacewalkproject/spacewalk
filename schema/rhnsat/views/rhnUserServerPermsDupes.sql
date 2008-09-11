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
