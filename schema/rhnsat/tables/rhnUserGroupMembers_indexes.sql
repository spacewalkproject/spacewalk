-- $Id$

create unique index rhn_ugmembers_uid_ugid_uq
	on rhnUserGroupMembers(user_id, user_group_id)
	parallel 6
	tablespace [[8m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32;

create index rhn_ugmembers_ugid_uid_idx
	on rhnUserGroupMembers(user_group_id, user_id)
	parallel 6
	tablespace [[8m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32
	nologging;


-- $Log$
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
