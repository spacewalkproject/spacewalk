--
-- $Id: $
--

create table rhnSGTypeVirtSubLevel (
    server_group_type_id    number
                            constraint rhn_sgtvsl_sgtid_nn not null
                            constraint rhn_sgtvsl_sgtid_fk
                                references rhnServerGroupType(id),
    virt_sub_level_id number
                      constraint rhn_sgtvsl_vslid_nn not null
                      constraint rhn_sgtvsl_vslid_fk
                        references rhnVirtSubLevel(id),
    created           date
                      default sysdate
                      constraint rhn_sgtvsl_created_nn not null,
    modified          date
                      default sysdate
                      constraint rhn_sgtvsl_modified_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create index rhn_sgtvsl_sgtid_vslid
    on rhnSGTypeVirtSubLevel(server_group_type_id, virt_sub_level_id)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_sgtvsl_vslid_sgtid
    on rhnSGTypeVirtSubLevel(virt_sub_level_id, server_group_type_id)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;




                                    
