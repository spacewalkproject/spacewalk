--
-- $Id$
--

create or replace view rhnUserChannelFamilyPerms as
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
	where	u.org_id = pcf.org_id;

--
-- $Log$
-- Revision 1.2  2004/04/16 16:07:12  pjones
-- bugzilla: none -- 8.1.7 won't let you use "null foo" as a column in a view
-- that gets unioned with a typed column.  you have to use "to_number(null) foo".  What a load of crap.
--
-- Revision 1.1  2004/04/14 15:58:39  pjones
-- bugzilla: none -- make rhnUserChannel work without org_id... (duh...)
--
