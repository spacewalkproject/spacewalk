CREATE INDEX rhn_actioncr_sid_idx
    ON rhnActionConfigRevision (server_id)
    TABLESPACE [[2m_tbs]];

DROP INDEX rhn_actioncr_sid_aid_idx;
