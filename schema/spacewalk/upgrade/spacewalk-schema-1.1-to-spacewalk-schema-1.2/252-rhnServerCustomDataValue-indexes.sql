CREATE INDEX rhn_scdv_kid_idx
    ON rhnServerCustomDataValue (key_id);
drop index rhn_scdv_kid_sid_idx;
