CREATE INDEX rhn_sat_cf_cfid_idx
    ON rhnSatelliteChannelFamily (channel_family_id)
    TABLESPACE [[2m_tbs]];
drop index rhn_sat_cf_cfid_sid_idx;
