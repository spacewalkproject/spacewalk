-- 
-- $Id$
-- EXCLUDE: all

-- This really sucks.  We shouldn't have seperate databases for every mail tool.
create table
cheetah_unsubscribe
(
	address		varchar2(128)
)
	storage ( freelists 16 )
	initrans 32;

create index cheetah_unsub_address_idx
	on cheetah_unsubscribe ( address )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.2  2003/11/05 16:40:22  pjones
-- bugzilla: 106071 -- these are of historical interest only, I _think_.
--
-- Revision 1.1  2003/04/15 19:08:51  pjones
-- bugzilla: 88948
--
-- ugly tables to keep track of email addresses for deleted users
-- so that they can be removed from some other database later.
--
