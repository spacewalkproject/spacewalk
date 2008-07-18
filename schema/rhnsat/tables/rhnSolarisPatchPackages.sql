
-- $Id$
create table rhnSolarisPatchPackages (
   patch_id             number
                        constraint rhn_solaris_pp_nn not null
                        constraint rhn_solaris_pp_fk references rhnPackage(id)
                        on delete cascade,
   package_nevra_id     number
                        constraint rhn_solaris_pnid_nn not null
                        constraint rhn_solaris_pnid_fk references rhnPackageNEVRA(id)
                        on delete cascade
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
enable row movement
initrans 32;

create index rhn_solaris_pp_pid_pnid_idx
on rhnSolarisPatchPackages (patch_id, package_nevra_id)
storage ( freelists 16 )
initrans 32;

create index rhn_solaris_pp_pnid_pid_idx
on rhnSolarisPatchPackages (package_nevra_id, patch_id)
storage ( freelists 16 )
initrans 32;


-- $Log$
