CREATE INDEX rhn_actioncc_sid_idx
    ON rhnActionConfigChannel (server_id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_act_cc_ccid_idx
    ON rhnActionConfigChannel (config_channel_id)
    TABLESPACE [[4m_tbs]];

DROP INDEX rhn_actioncc_sid_aid_ccid_idx;
DROP INDEX rhn_act_cc_ccid_aid_sid_idx;
