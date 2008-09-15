
drop index rhn_package_n_e_pa_o_uq;
drop index rhn_package_md5_nid_eid_oid_uq;

create unique index rhn_package_md5_oid_uq
	on rhnPackage(md5sum, org_id)
	tablespace [[2m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32;

