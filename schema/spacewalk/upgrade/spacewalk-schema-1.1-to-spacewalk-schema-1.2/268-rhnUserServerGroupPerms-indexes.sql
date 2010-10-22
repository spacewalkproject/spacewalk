CREATE INDEX rhn_usgp_sg_idx
    ON rhnUserServerGroupPerms (server_group_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;
drop index rhn_usgp_sg_u_p_idx;
