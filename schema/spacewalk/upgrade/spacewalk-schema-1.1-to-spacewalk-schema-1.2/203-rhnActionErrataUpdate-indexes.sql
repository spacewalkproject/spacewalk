CREATE INDEX rhn_act_eu_eid_idx
    ON rhnActionErrataUpdate (errata_id)
    TABLESPACE [[8m_tbs]];

DROP INDEX rhn_act_eu_eid_aid_idx;
