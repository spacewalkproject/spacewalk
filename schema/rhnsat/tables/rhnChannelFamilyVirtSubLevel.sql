--
-- $Id:$
--

create table rhnChannelFamilyVirtSubLevel (
    channel_family_id number
                      constraint rhn_cfvsl_cfid_nn not null
                      constraint rhn_cfvsl_cfid_fk 
                        references rhnChannelFamily(id),
    virt_sub_level_id number
                      constraint rhn_cfvsl_vslid_nn not null
                      constraint rhn_cfvsl_vslid_fk
                        references rhnVirtSubLevel(id),
    created           date 
                      default sysdate
                      constraint rhn_cfvsl_created_nn not null,
    modified          date
                      default sysdate
                      constraint rhn_cfvsl_modified_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create index rhn_cfvsl_cfid_vslid_idx
    on rhnChannelFamilyVirtSubLevel(channel_family_id, virt_sub_level_id)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_cfvsl_vslid_cfid_idx
    on rhnChannelFamilyVirtSubLevel(virt_sub_level_id, channel_family_id)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;




