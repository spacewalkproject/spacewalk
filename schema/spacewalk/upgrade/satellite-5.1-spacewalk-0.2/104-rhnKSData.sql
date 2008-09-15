
alter table rhnKSData
add kscfg      char(1) default('N')
                constraint rhn_ks_cfg_save_nn not null
                constraint rhn_ks_cfg_save_ck
                    check (kscfg in ('Y','N'));

