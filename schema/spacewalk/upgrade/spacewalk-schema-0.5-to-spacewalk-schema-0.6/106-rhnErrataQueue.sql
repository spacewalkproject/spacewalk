-- Clear any preexisting tasks before the upgrade
delete from rhnErrataQueue;

-- Add a channel_id column, whcih is non null 
-- and fk to rhnChannel
ALTER TABLE rhnErrataQueue
  ADD channel_id number
CONSTRAINT rhn_equeue_cid_nn NOT NULL
CONSTRAINT rhn_equeue_cid_fk
    REFERENCES rhnChannel(id);

-- Drop unique constraint on errata_id
ALTER TABLE rhnErrataQueue DROP CONSTRAINT rhn_equeue_eoid_uq;

show errors
