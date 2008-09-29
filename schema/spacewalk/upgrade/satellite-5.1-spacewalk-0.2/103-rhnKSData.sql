
alter table rhnKSData
add preLog     char(1) default('N')
                constraint rhn_ks_pre_log_nn not null
                constraint rhn_ks_pre_log_ck
                    check (preLog in ('Y','N'));

