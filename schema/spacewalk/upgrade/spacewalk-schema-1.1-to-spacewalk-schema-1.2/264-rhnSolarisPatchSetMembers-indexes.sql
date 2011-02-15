CREATE INDEX rhn_solaris_psm_psid_idx
    ON rhnSolarisPatchSetMembers (patch_set_id)
    TABLESPACE [[4m_tbs]];
drop index rhn_solaris_psm_psid_pid_idx;
