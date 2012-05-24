insert into rhnChannelArch (id, label, name, arch_type_id) values
        (sequence_nextval('rhn_channel_arch_id_seq'), 'channel-armhfp', 'ARM hard. FP', lookup_arch_type('rpm'));

insert into rhnPackageArch (id, label, name, arch_type_id) values
        (sequence_nextval('rhn_package_arch_id_seq'), 'armv7hnl', 'ARMv7hnl', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
        (sequence_nextval('rhn_package_arch_id_seq'), 'armv7hl', 'ARMv7hl', lookup_arch_type('rpm'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('armv7hnl'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('armv7hl'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv7l-redhat-linux', 'armv7l', lookup_arch_type('rpm'));


insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-armhfp'));


insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv7l-redhat-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv7l-redhat-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv7l-redhat-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv7l-redhat-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
        values (lookup_server_arch('armv7l-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'armv7l', 'ARMv7l');
