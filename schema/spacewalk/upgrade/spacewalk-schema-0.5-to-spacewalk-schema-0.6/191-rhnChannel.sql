-- Add a checksum_type_id column, and fk to rhnChecksumType
ALTER TABLE rhnChannel
  ADD checksum_type_id number
CONSTRAINT rhn_channel_checksum_fk
    REFERENCES rhnChecksumType(id);

show errors
