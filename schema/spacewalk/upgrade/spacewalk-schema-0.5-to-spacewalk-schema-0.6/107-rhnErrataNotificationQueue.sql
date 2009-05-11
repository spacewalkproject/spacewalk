-- Clear any preexisting tasks before the upgrade
delete from rhnErrataNotificationQueue;

-- Add a channel_id column, whcih is non null
-- and fk to rhnChannel
ALTER TABLE rhnErrataNotificationQueue
  ADD channel_id number
CONSTRAINT rhn_enqueue_nn NOT NULL
CONSTRAINT rhn_enqueue_cid_fk
    REFERENCES rhnChannel(id);

show errors

