insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
    values (lookup_server_arch('aarch64-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
    values (lookup_server_arch('ppc64le-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));

