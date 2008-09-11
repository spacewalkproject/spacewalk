--
-- $Id$
--
-- this shows us where rhnChannelFamilyPermissions.current_members is wrong.
-- ts=4, fwiw.

select	rcfp.org_id					org_id,
		rcfp.current_members		bad_current_members,
		count(s.id)					real_current_members
from
		rhnServer					s,
		rhnServerChannel			sc,
		rhnChannelFamilyMembers		rcfm,
		rhnChannelFamilyPermissions	rcfp
where	1=1
	and rcfp.channel_family_id = rcfm.channel_family_id
	and rcfm.channel_id = sc.channel_id
	and sc.server_id = s.id
	and rcfp.org_id = s.org_id
group by
		rcfp.org_id, rcfp.current_members
having rcfp.current_members != count(s.id)

-- $Log$
-- Revision 1.1  2002/11/20 22:04:35  pjones
-- query to find incorrect rhnChannelFamilyPermissions
--
