-- $Id$
--
-- associate ServerGroups with audit actions
--
-- EXCLUDE: all

create table
rhnAuditTrailServerGroup
(
	trail_id	number
			constraint rhn_atrailsgroup_tid_nn not null
			constraint rhn_atrailsgroup_tid_fk
				references rhnAuditTrail(id),
	server_group_id	number
			constraint rhn_atrailsgroup_sgid_nn not null
			constraint rhn_atrailsgroup_sgid_fk
				references rhnServerGroup(id)
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_atrailsgroup_tid_sgid_idx
	on rhnAuditTrailServerGroup(trail_id, server_group_id)
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create index rhn_atrailsgroup_sgid_uid_idx
	on rhnAuditTrailServerGroup(server_group_id, trail_id)
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/12/02 15:19:26  pjones
-- audit trail schema
--
