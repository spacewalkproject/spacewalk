-- created by Oraschemadoc Mon Aug 31 10:54:30 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNCHANNELFAMILYSERVERS" ("CUSTOMER_ID", "CHANNEL_FAMILY_ID", "SERVER_ID", "CREATED", "MODIFIED") AS 
  select	rs.org_id			as customer_id,
		rcfm.channel_family_id		as channel_family_id,
		rsc.server_id			as server_id,
		rsc.created			as created,
		rsc.modified			as modified
	from	rhnChannelFamilyMembers		rcfm,
		rhnChannelFamily		rcf,
		rhnServerChannel		rsc,
		rhnServer			rs
	where
		rcfm.channel_id = rsc.channel_id
		and rcfm.channel_family_id = rcf.id
		and rsc.server_id = rs.id
 
/
