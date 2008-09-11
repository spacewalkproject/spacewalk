--
-- $Id$
--

create or replace view rhnOrgChannelFamilyPermissions as
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
	from	rhnPrivateChannelFamily;

--
-- $Log$
-- Revision 1.2  2004/04/16 16:07:12  pjones
-- bugzilla: none -- 8.1.7 won't let you use "null foo" as a column in a view
-- that gets unioned with a typed column.  you have to use "to_number(null) foo".  What a load of crap.
--
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
