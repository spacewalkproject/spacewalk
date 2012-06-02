insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'armv6l', 'ARMv6l');

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv6l-redhat-linux', 'armv6l', lookup_arch_type('rpm'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('armv6l-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-arm'));

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv6l-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv6l'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv6l-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv5tel'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv6l-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv6l-redhat-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv6l-redhat-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv6l-redhat-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv6l-redhat-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv6l-redhat-linux'),
            lookup_sg_type('virtualization_host'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv6l-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));
