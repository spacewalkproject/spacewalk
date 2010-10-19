ALTER TABLE rhnErrataNotificationQueue DROP CONSTRAINT rhn_enqueue_eoid_uq;
ALTER TABLE rhnErrataNotificationQueue
    ADD CONSTRAINT rhn_enqueue_eoid_uq UNIQUE (errata_id, channel_id, org_id);
