CREATE INDEX RHN_SRVR_TKN_RGS_SID_IDX
    ON rhnServerTokenRegs (server_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;
drop index RHN_SRVR_TKN_RGS_SID_TID_IDX;
