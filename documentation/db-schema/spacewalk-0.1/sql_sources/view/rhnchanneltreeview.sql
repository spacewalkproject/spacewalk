-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNCHANNELTREEVIEW" ("ID", "DEPTH", "NAME", "PADDED_NAME", "CHANNEL_ARCH_ID", "LAST_MODIFIED", "LABEL", "PARENT_OR_SELF_LABEL", "PARENT_OR_SELF_ID", "END_OF_LIFE") AS 
  select "ID","DEPTH","NAME","PADDED_NAME","CHANNEL_ARCH_ID","LAST_MODIFIED","LABEL","PARENT_OR_SELF_LABEL","PARENT_OR_SELF_ID","END_OF_LIFE" from (
	select	c.id			id,
		1			depth,
		c.name			name,
		'  ' || c.name		padded_name,
		c.channel_arch_id	channel_arch_id,
		c.last_modified		last_modified,
		c.label			label,
		c.label			parent_or_self_label,
		c.id			parent_or_self_id,
		c.end_of_life		end_of_life
	from	rhnChannel		c
	where	c.parent_channel is null
	union
	select	c.id			id,
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
		rhnChannel		c
	where	c.parent_channel = pc.id
) order by parent_or_self_label, parent_or_self_id
 
/
