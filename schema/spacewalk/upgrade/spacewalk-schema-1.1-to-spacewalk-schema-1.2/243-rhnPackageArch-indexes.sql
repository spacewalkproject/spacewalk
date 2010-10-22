ALTER TABLE rhnPackageArch
    disable CONSTRAINT rhn_parch_label_uq;
drop index rhn_parch_l_id_n_idx;
ALTER TABLE rhnPackageArch
    enable CONSTRAINT rhn_parch_label_uq;
