drop index rhn_ss_tag_tid_ssid_idx;

CREATE INDEX rhn_ss_tag_tid_idx
    ON rhnSnapshotTag (tag_id);
drop index rhn_ss_tag_tid_sid_idx;
