-- created by Oraschemadoc Fri Mar  2 05:57:59 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNORGCHANNELFAMILYPERMISSIONS" ("CHANNEL_FAMILY_ID", "ORG_ID", "MAX_MEMBERS", "CURRENT_MEMBERS", "FVE_MAX_MEMBERS", "FVE_CURRENT_MEMBERS", "CREATED", "MODIFIED") AS 
  select	pcf.channel_family_id,
		u.org_id as org_id,
		to_number(null, null) as max_members,
		0 as current_members,
		to_number(null, null) as fve_max_members,
		0 as fve_current_members,
		pcf.created,
		pcf.modified
	from	rhnPublicChannelFamily pcf,
		web_contact u
	union
	select	channel_family_id,
		org_id,
		max_members,
		current_members,
		fve_max_members,
		fve_current_members,
		created,
		modified
	from	rhnPrivateChannelFamily
 
/
