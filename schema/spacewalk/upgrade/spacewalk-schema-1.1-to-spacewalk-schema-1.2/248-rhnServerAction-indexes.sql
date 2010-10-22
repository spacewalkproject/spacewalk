CREATE INDEX rhn_ser_act_aid_idx
    ON rhnServerAction (action_id)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;
drop index rhn_ser_act_aid_sid_s_idx;
