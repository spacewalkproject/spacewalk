CREATE INDEX rhn_ssg_ac_sgt_idx
    ON rhnServerServerGroupArchCompat (server_group_type)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;
drop index rhn_ssg_ac_sgt_said_idx;
