-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNORGCHANNELFAMILYPERMISSIONS" ("CHANNEL_FAMILY_ID", "ORG_ID", "MAX_MEMBERS", "CURRENT_MEMBERS", "CREATED", "MODIFIED") AS 
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
