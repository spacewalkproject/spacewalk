
-- $Id$
create table rhnSolarisPatchedPackage (
   server_id            number
                        constraint rhn_solaris_patchedp_sid_nn not null
                        constraint rhn_solaris_patchedp_sid_fk references rhnServer(id)
                        on delete cascade,
   patch_id             number
                        constraint rhn_solaris_patchedp_pid_nn not null
                        constraint rhn_solaris_patchedp_pid_fk references rhnPackage(id)
                        on delete cascade,
   package_nevra_id     number
                        constraint rhn_solaris_patchedp_pnid_nn not null
                        constraint rhn_solaris_patchedp_pnid_fk references rhnPackageNEVRA(id)
                        on delete cascade
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
enable row movement
initrans 32;

create index rhn_solaris_patchedp_sid_idx
on rhnSolarisPatchedPackage ( server_id )
   tablespace [[8m_tbs]]
   storage( pctincrease 1 freelists 16 )
   initrans 32
   nologging;

-- $Log$
