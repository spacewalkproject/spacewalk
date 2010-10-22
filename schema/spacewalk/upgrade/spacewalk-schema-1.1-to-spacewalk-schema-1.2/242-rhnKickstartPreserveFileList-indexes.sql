CREATE INDEX rhn_kspreservefl_flid_idx
    ON rhnKickstartPreserveFileList (file_list_id)
    TABLESPACE [[8m_tbs]];
drop index rhn_kspreservefl_flid_ksid_idx;
