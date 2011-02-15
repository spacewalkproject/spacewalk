CREATE INDEX rhn_solaris_pp_pnid_idx
    ON rhnSolarisPatchPackages (package_nevra_id);
drop index rhn_solaris_pp_pnid_pid_idx;
