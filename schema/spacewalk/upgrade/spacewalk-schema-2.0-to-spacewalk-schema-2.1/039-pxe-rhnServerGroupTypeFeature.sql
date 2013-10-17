insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('bootstrap_entitled'), lookup_feature_type('ftr_kickstart'),
        current_timestamp,current_timestamp);

