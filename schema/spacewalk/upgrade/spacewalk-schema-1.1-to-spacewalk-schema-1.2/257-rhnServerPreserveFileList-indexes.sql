CREATE INDEX rhn_serverpfl_flid_idx
    ON rhnServerPreserveFileList (file_list_id)
    TABLESPACE [[4m_tbs]];
drop index rhn_serverpfl_flid_ksid_idx;
