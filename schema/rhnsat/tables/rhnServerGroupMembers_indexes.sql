-- $Id$

create unique index rhn_sgmembers_sid_sgid_uq
	on rhnServerGroupMembers(server_id, server_group_id)
	tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32;

create index rhn_sgmembers_sgid_sid_idx
	on rhnServerGroupMembers(server_group_id, server_id)
	parallel 6
        tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
