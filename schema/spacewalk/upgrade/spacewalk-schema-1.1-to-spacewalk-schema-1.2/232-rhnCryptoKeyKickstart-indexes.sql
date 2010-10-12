CREATE INDEX rhn_ckey_ks_idx
    ON rhnCryptoKeyKickstart (ksdata_id)
    TABLESPACE [[4m_tbs]];

DROP INDEX rhn_ckey_ks__ckuq;
