-- created by Oraschemadoc Mon Aug 31 10:54:31 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNCHANNELTREEVIEW" ("ID", "DEPTH", "NAME", "PADDED_NAME", "CHANNEL_ARCH_ID", "LAST_MODIFIED", "LABEL", "PARENT_OR_SELF_LABEL", "PARENT_OR_SELF_ID", "END_OF_LIFE") AS 
  select "ID","DEPTH","NAME","PADDED_NAME","CHANNEL_ARCH_ID","LAST_MODIFIED","LABEL","PARENT_OR_SELF_LABEL","PARENT_OR_SELF_ID","END_OF_LIFE" from (
	select	c.id			as id,
		1			as depth,
		c.name			as name,
		'  ' || c.name		as padded_name,
		c.channel_arch_id	as channel_arch_id,
		c.last_modified		as last_modified,
		c.label			as label,
		c.label			as parent_or_self_label,
		c.id			as parent_or_self_id,
		c.end_of_life		as end_of_life
	from	rhnChannel		c
	where	c.parent_channel is null
	union
	select	c.id			as id,
		2			as depth,
		c.name			as name,
		'' || c.name		as padded_name,
		c.channel_arch_id 	as channel_arch_id,
		c.last_modified		as last_modified,
		c.label			as label,
		pc.label		as parent_or_self_label,
		pc.id			as parent_or_self_id,
		c.end_of_life		as end_of_life
	from	rhnChannel		pc,
		rhnChannel		c
	where	c.parent_channel = pc.id
) S order by parent_or_self_label, parent_or_self_id
 
/
