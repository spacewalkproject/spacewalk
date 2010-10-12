CREATE INDEX rhn_actioncf_name_sid_idx
    ON rhnActionConfigFileName (server_id)
    TABLESPACE [[2m_tbs]];

DROP INDEX rhn_actioncf_name_sac_uq;
