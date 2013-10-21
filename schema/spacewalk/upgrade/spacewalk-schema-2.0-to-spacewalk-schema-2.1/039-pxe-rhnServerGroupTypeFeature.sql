insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id)
values (lookup_sg_type('bootstrap_entitled'), lookup_feature_type('ftr_kickstart'));

insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id)
values (lookup_sg_type('bootstrap_entitled'), lookup_feature_type('ftr_system_grouping'));

