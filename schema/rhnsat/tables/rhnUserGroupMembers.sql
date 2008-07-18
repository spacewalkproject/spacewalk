--
-- $Id$
--

create table
rhnUserGroupMembers
(
	user_id		number
			constraint rhn_ugmembers_uid_nn not null
			constraint rhn_ugmembers_uid_fk
				references web_contact(id)
				on delete cascade,
	user_group_id	number
			constraint rhn_ugmembers_ugid_nn not null
			constraint rhn_ugmembers_ugid_fk
				references rhnUserGroup(id),
	created		date default(sysdate)
			constraint rhn_ugmembers_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_ugmembers_modified_nn not null
)
	storage ( pctincrease 1 freelists 16 )
	enable row movement
	initrans 32;

-- $Log$
-- Revision 1.16  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.15  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.14  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
