-- created by Oraschemadoc Fri Mar  2 05:57:58 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNCHANNELFAMILYSERVERFVE" ("CUSTOMER_ID", "CHANNEL_FAMILY_ID", "SERVER_ID", "CREATED", "MODIFIED") AS 
  select	rs.org_id			customer_id,
		rcfm.channel_family_id	channel_family_id,
		rsc.server_id			server_id,
		rsc.created			created,
		rsc.modified			modified
	from	rhnChannelFamilyMembers		rcfm,
		rhnChannelFamily		rcf,
		rhnServerChannel		rsc,
		rhnServer			rs
	where
		rcfm.channel_id = rsc.channel_id
		and rcfm.channel_family_id = rcf.id
		and rsc.server_id = rs.id
		and rsc.is_fve = 'Y'
 
/
