DROP INDEX rhn_server_dmi_sid_idx;

CREATE UNIQUE INDEX rhn_server_dmi_sid_uq
    ON rhnServerDMI (server_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;
