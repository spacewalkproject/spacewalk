
drop index rhn_snpc_pid_eid_sid_idx;
drop index rhn_snpc_sid_pid_eid_idx;
drop index rhn_snpc_eid_sid_pid_idx;
drop index rhn_snpc_oid_eid_sid_idx;

create index rhn_snpc_pid_idx
	on rhnServerNeededPackageCache(package_id)
	parallel
	tablespace [[128m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	pctfree 10
	initrans 32
	nologging;
 
create index rhn_snpc_sid_idx
	on rhnServerNeededPackageCache(server_id)
	parallel
	tablespace [[128m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	pctfree 10
	initrans 32
	nologging;
 
create index rhn_snpc_eid_idx
	on rhnServerNeededPackageCache(errata_id)
	parallel
	tablespace [[128m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	pctfree 10
	initrans 32
	nologging;
 
create index rhn_snpc_oid_idx
	on rhnServerNeededPackageCache(org_id)
	parallel
	tablespace [[128m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	pctfree 10
	initrans 32
	nologging;

