-- created by Oraschemadoc Fri Mar  2 05:57:58 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNCHANNELFAMILYPERMISSIONS" ("CHANNEL_FAMILY_ID", "ORG_ID", "MAX_MEMBERS", "CURRENT_MEMBERS", "FVE_MAX_MEMBERS", "FVE_CURRENT_MEMBERS", "CREATED", "MODIFIED") AS 
  select	channel_family_id,
		to_number(null, null) as org_id,
		to_number(null, null) as max_members,
		0 as current_members,
                0 as fve_max_members,
                0 as fve_current_members,
		created,
		modified
	from	rhnPublicChannelFamily
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
