-- $Id$

create index rhn_sg_id_oid_name_idx
	on rhnServerGroup(id,org_id,name)
	parallel 6
        tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;
	
create index rhn_sg_oid_id_name_idx
	on rhnServerGroup(org_id,id,name)
	parallel 6
        tablespace [[8m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;
	
create index rhn_sg_type_id_idx
	on rhnServerGroup(group_type,id)
	parallel 6
        tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;
	
create index rhn_sg_oid_type_id_idx
	on rhnServerGroup(org_id, group_type, id)
	parallel 6
        tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
