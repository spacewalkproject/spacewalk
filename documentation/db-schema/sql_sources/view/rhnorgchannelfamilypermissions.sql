-- created by Oraschemadoc Fri Jan 22 13:40:43 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNORGCHANNELFAMILYPERMISSIONS" ("CHANNEL_FAMILY_ID", "ORG_ID", "MAX_MEMBERS", "CURRENT_MEMBERS", "CREATED", "MODIFIED") AS
  select	pcf.channel_family_id,
		u.org_id org_id,
		to_number(null) max_members,
		0 current_members,
		pcf.created,
		pcf.modified
	from	rhnPublicChannelFamily pcf,
		web_contact u
	union
	select	channel_family_id,
		org_id,
		max_members,
		current_members,
		created,
		modified
	from	rhnPrivateChannelFamily
 
/
