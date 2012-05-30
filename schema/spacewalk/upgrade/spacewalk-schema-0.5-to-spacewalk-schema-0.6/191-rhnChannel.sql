-- Add a checksum_type_id column, and fk to rhnChecksumType
ALTER TABLE rhnChannel
  ADD checksum_type_id number
CONSTRAINT rhn_channel_checksum_fk
    REFERENCES rhnChecksumType(id);

alter trigger rhn_channel_mod_trig disable;

-- Update any existing channels that are not set
UPDATE rhnChannel SET 
  checksum_type_id = (select id 
                        from rhnChecksumType 
                       where LABEL = 'sha1')
WHERE checksum_type_id is null;

alter trigger rhn_channel_mod_trig enable;

show errors
