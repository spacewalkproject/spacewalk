-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNCHANNELFAMILYPERMISSIONS" ("CHANNEL_FAMILY_ID", "ORG_ID", "MAX_MEMBERS", "CURRENT_MEMBERS", "CREATED", "MODIFIED") AS 
  select	channel_family_id,
		to_number(null) org_id,
		to_number(null) max_members,
		0 current_members,
		created,
		modified
	from	rhnPublicChannelFamily
	union
	select	channel_family_id,
		org_id,
		max_members,
		current_members,
		created,
		modified
	from	rhnPrivateChannelFamily
 
/
