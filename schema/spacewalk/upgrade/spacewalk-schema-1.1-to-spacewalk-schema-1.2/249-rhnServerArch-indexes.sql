ALTER TABLE rhnServerArch
    disable CONSTRAINT rhn_sarch_label_uq;
drop index rhn_sarch_l_id_n_idx;
ALTER TABLE rhnServerArch
    enable CONSTRAINT rhn_sarch_label_uq;
