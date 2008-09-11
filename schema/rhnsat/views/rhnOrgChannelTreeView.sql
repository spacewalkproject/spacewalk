--
-- $Id$
--

CREATE OR REPLACE VIEW rhnOrgChannelTreeView
(
	org_id,
        id,
        depth,
	name,
        padded_name,
	channel_arch_id,
        last_modified,
        label,
	parent_or_self_label,
	parent_or_self_id,
	end_of_life
)
AS
select * from (
	select	cfp.org_id		org_id,
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
		rhnOrgChannelFamilyPermissions cfp
	where	cfp.channel_family_id = cfm.channel_family_id
		and cfm.channel_id = c.id
		and c.parent_channel is null
	union
	select	cfp.org_id		org_id,
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
		rhnOrgChannelFamilyPermissions cfp
	where	cfp.channel_family_id = cfm.channel_family_id
		and cfm.channel_id = c.id
		and c.parent_channel = pc.id
) order by parent_or_self_label, parent_or_self_id;

--
-- $Log$
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
