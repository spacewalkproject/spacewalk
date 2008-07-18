
-- $Id$
create table rhnActionPackageOrder (
   action_package_id       number
                           constraint rhn_act_pkg_apid_nn not null
                           constraint rhn_act_pkg_apid_fk references rhnActionPackage(id)
                           on delete cascade,
   package_order           number
                           constraint rhn_act_pkg_order_nn not null
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
	enable row movement
initrans 32;

create index rhn_act_pkg_apid_idx
on rhnActionPackageOrder (action_package_id)
tablespace [[32m_tbs]]
storage ( freelists 16 )
initrans 32;


-- $Log$
