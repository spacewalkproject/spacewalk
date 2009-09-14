-- created by Oraschemadoc Mon Aug 31 10:54:34 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNUSERCHANNELFAMILYPERMS" ("CHANNEL_FAMILY_ID", "ORG_ID", "USER_ID", "MAX_MEMBERS", "CURRENT_MEMBERS", "CREATED", "MODIFIED") AS 
  select	pcf.channel_family_id,
		u.org_id org_id,
		u.id user_id,
		to_number(null) max_members,
		0 current_members,
		pcf.created,
		pcf.modified
	from	rhnPublicChannelFamily pcf,
		web_contact u
	union
	select	pcf.channel_family_id,
		u.org_id,
		u.id user_id,
		pcf.max_members,
		pcf.current_members,
		pcf.created,
		pcf.modified
	from	rhnPrivateChannelFamily pcf,
		web_contact u
	where	u.org_id = pcf.org_id
 
/
