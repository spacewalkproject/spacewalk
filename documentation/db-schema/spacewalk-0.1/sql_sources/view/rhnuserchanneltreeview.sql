-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNUSERCHANNELTREEVIEW" ("USER_ID", "ORG_ID", "ID", "DEPTH", "NAME", "PADDED_NAME", "CHANNEL_ARCH_ID", "LAST_MODIFIED", "LABEL", "PARENT_OR_SELF_LABEL", "PARENT_OR_SELF_ID", "END_OF_LIFE") AS 
  select "USER_ID","ORG_ID","ID","DEPTH","NAME","PADDED_NAME","CHANNEL_ARCH_ID","LAST_MODIFIED","LABEL","PARENT_OR_SELF_LABEL","PARENT_OR_SELF_ID","END_OF_LIFE" from (
	select	cfp.user_id		user_id,
		cfp.org_id		org_id,
		c.id			id,
		1			depth,
		c.name			name,
		'  ' || c.name		padded_name,
		c.channel_arch_id	channel_arch_id,
		c.last_modified		last_modified,
		c.label			label,
		c.label			parent_or_self_label,
		c.id			parent_or_self_id,
		c.end_of_life		end_of_life
	from	rhnChannel		c,
		rhnChannelFamilyMembers cfm,
		rhnUserChannelFamilyPerms cfp
	where	1=1
		and cfp.channel_family_id = cfm.channel_family_id
		and cfm.channel_id = c.id
		and c.parent_channel is null
	union
	select	cfp.user_id		user_id,
		cfp.org_id		org_id,
		c.id			id,
		2			depth,
		c.name			name,
		'' || c.name		padded_name,
		c.channel_arch_id 	channel_arch_id,
		c.last_modified		last_modified,
		c.label			label,
		pc.label		parent_or_self_label,
		pc.id			parent_or_self_id,
		c.end_of_life		end_of_life
	from	rhnChannel		pc,
		rhnChannel		c,
		rhnChannelFamilyMembers	cfm,
		rhnUserChannelFamilyPerms cfp
	where	1=1
		and cfp.channel_family_id = cfm.channel_family_id
		and cfm.channel_id = c.id
		and c.parent_channel = pc.id
) order by parent_or_self_label, parent_or_self_id
 
/
