CREATE INDEX rhn_sscr_crid_idx
    ON rhnSnapshotConfigRevision (config_revision_id)
    TABLESPACE [[2m_tbs]];
drop index rhn_sscr_crid_sid_idx;
