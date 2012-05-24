insert into rhnChannelArch (id, label, name, arch_type_id) values
        (sequence_nextval('rhn_channel_arch_id_seq'), 'channel-arm', 'ARM soft. FP', lookup_arch_type('rpm'));

insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv7l', 'ARMv7l', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv6l', 'ARMv6l', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv5tel', 'ARMv5tel', lookup_arch_type('rpm'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv7l'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv6l'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv5tel'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
		values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv5tejl-redhat-linux', 'armv5tejl', lookup_arch_type('rpm'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
        (LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-arm'));
insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
        (LOOKUP_SERVER_ARCH('armv5tejl-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-arm'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv5tejl-redhat-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv5tejl-redhat-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv5tejl-redhat-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv5tejl-redhat-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv5tejl-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'armv5tejl', 'ARMv5tejl');
