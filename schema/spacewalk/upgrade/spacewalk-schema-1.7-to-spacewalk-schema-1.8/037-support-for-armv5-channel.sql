insert into rhnChannelArch (id, label, name, arch_type_id) values
        (sequence_nextval('rhn_channel_arch_id_seq'), 'channel-arm', 'ARM soft. FP', lookup_arch_type('rpm'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv7l'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv6l'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv5tel'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
		values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
        (LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-arm'));
