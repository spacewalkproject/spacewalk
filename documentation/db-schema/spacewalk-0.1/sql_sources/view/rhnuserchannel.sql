-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNUSERCHANNEL" ("USER_ID", "ORG_ID", "CHANNEL_ID", "ROLE") AS 
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
		cfp.user_id, 'subscribe') = 1
 
/
