alter table rhnChannelArch drop CONSTRAINT rhn_carch_label_uq;
ALTER TABLE rhnChannelArch
    ADD CONSTRAINT rhn_carch_label_uq UNIQUE (label)
    USING INDEX TABLESPACE [[2m_tbs]];

drop index rhn_carch_id_l_n_idx;
