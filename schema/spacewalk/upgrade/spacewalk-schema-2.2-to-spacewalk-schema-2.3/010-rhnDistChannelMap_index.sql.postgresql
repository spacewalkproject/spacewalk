-- oracle equivalent source sha1 31bc60e73b873355d9251bbea814bf57fd3a4c87

alter table rhnDistChannelMap drop constraint rhn_dcm_release_caid_oid_uq;

create unique index rhn_dcm_rel_caid_oid_uq_idx
    on rhnDistChannelMap (release, channel_arch_id, org_id)
 where org_id is not null;

create unique index rhn_dcm_rel_caid_uq_idx
    on rhnDistChannelMap (release, channel_arch_id)
 where org_id is null;

