--
-- $Id$
--

create or replace view rhnChannelFamilyServers as
	select	rs.org_id			customer_id,
		rcfm.channel_family_id		channel_family_id,
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
		and rsc.server_id = rs.id;

-- $Log$
-- Revision 1.3  2003/04/11 20:46:21  cturner
-- bugzilla: 85923.  begone purchasable flag
--
-- Revision 1.2  2002/05/15 21:30:09  pjones
-- id/log
--
