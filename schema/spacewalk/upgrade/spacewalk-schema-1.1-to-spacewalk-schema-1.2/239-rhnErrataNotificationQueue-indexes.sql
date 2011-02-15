ALTER TABLE rhnErrataNotificationQueue
    disable CONSTRAINT rhn_enqueue_eoid_uq;
drop index rhn_enqueue_eid_idx;
ALTER TABLE rhnErrataNotificationQueue
    enable CONSTRAINT rhn_enqueue_eoid_uq;

CREATE INDEX rhn_enqueue_na_idx
    ON rhnErrataNotificationQueue (next_action)
     TABLESPACE [[8m_tbs]];
drop index rhn_enqueue_na_eid_idx;
