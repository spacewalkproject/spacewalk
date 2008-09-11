--
-- $Id$
--

create table
rhnUserServerPerms
(
	user_id		number
			constraint rhn_usperms_uid_nn not null
			constraint rhn_usperms_uid_fk
				references web_contact(id),
	server_id	number
			constraint rhn_usperms_sid_nn not null
			constraint rhn_usperms_sid_fk
				references rhnServer(id)
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_usperms_uid_sid_uq
	on rhnUserServerPerms( user_id, server_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_usperms_sid_idx
	on rhnUserServerPerms( server_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
-- $Log$
-- Revision 1.1  2004/07/02 18:57:04  pjones
-- bugzilla: 125937 -- to which servers does a user have permissions.
--
