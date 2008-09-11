--
-- $Id$
--

create or replace view rhnUserChannel as
select	cfp.user_id		user_id,
	cfp.org_id		org_id,
	cfm.channel_id		channel_id,
	'manage'		role
from	rhnChannelFamilyMembers	cfm,
	rhnUserChannelFamilyPerms cfp
where	cfp.channel_family_id = cfm.channel_family_id
	and rhn_channel.user_role_check(cfm.channel_id,
		cfp.user_id, 'manage') = 1
union all
select	cfp.user_id		user_id,
	cfp.org_id		org_id,
	cfm.channel_id		channel_id,
	'subscribe'		role
from	rhnChannelFamilyMembers	cfm,
	rhnUserChannelFamilyPerms cfp
where	cfp.channel_family_id = cfm.channel_family_id
	and rhn_channel.user_role_check(cfm.channel_id,
		cfp.user_id, 'subscribe') = 1;

--
-- $Log$
-- Revision 1.15  2004/04/28 14:57:02  pjones
-- bugzilla: 119698 -- Go back to a split version of this, like in 1.13.  We
-- don't need the distinct though; nothing can show up in either table twice.
--
-- Revision 1.13  2004/04/14 15:58:39  pjones
-- bugzilla: none -- make rhnUserChannel work without org_id... (duh...)
--
-- Revision 1.12  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
