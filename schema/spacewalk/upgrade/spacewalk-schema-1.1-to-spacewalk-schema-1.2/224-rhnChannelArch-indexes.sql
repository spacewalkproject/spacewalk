alter table rhnChannel disable constraint rhn_channel_caid_fk;
alter table rhnChannelPackageArchCompat disable constraint rhn_cp_ac_caid_fk;
alter table rhnDistChannelMap disable constraint rhn_dcm_caid_fk;
alter table rhnReleaseChannelMap disable constraint rhn_rcm_caid_fk;
alter table rhnServerChannelArchCompat disable constraint rhn_sc_ac_caid_fk;
alter table rhnChannelArch disable constraint rhn_carch_id_pk;
drop index rhn_carch_id_l_n_idx;
alter table rhnChannelArch enable constraint rhn_carch_id_pk;
alter table rhnChannel enable constraint rhn_channel_caid_fk;
alter table rhnChannelPackageArchCompat enable constraint rhn_cp_ac_caid_fk;
alter table rhnDistChannelMap enable constraint rhn_dcm_caid_fk;
alter table rhnReleaseChannelMap enable constraint rhn_rcm_caid_fk;
alter table rhnServerChannelArchCompat enable constraint rhn_sc_ac_caid_fk;

alter table rhnChannelArch drop CONSTRAINT rhn_carch_label_uq;
drop index rhn_carch_l_id_n_idx;
ALTER TABLE rhnChannelArch
    ADD CONSTRAINT rhn_carch_label_uq UNIQUE (label)
    USING INDEX TABLESPACE [[2m_tbs]];
