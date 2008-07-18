--
-- $Id: $ 
--

create table
rhnServerGroupTypeFeature
(
        server_group_type_id     number
                                 constraint rhn_sgt_sgtid_nn not null
                                 constraint rhn_sgt_sgid_fk references rhnServerGroupType(id),
        feature_id               number
                                 constraint rhn_sgt_fid_nn not null
                                 constraint rhn_sgt_fid_fk references rhnFeature(id),
        created                  date default(sysdate)
                                 constraint rhn_sgt_feat_created_nn not null,
        modified                 date default(sysdate)
                                 constraint rhn_sgt_feat_mod_nn not null
)
        storage ( freelists 16 )
	enable row movement
        initrans 32;

create unique index rhn_sgt_feat_sgtid_fid_uq_idx
        on rhnServerGroupTypeFeature(server_group_type_id, feature_id)
        tablespace [[64k_tbs]]
        storage ( freelists 16 )
        initrans 32;

