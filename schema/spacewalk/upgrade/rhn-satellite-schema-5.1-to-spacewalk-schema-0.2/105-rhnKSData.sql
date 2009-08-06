
alter table rhnKSData
add verboseup2date char(1) default('N')
                constraint rhn_ks_verbose_up2date_nn not null
                constraint rhn_ks_verbose_up2date_ck
                check (verboseup2date in ('Y','N'));

alter table rhnKSData
add nonchrootpost char(1) default('N')
                constraint rhn_ks_nonchroot_post_nn not null
                constraint rhn_ks_nonchroot_post_ck
                check (nonchrootpost in ('Y','N'));

