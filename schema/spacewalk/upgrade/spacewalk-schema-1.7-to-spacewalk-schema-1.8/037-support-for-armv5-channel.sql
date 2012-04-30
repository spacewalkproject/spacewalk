insert into rhnChannelArch (id, label, name, arch_type_id) values
        (sequence_nextval('rhn_channel_arch_id_seq'), 'channel-armv5', 'ARMv5', lookup_arch_type('rpm'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
        values (LOOKUP_CHANNEL_ARCH('channel-armv5'), LOOKUP_PACKAGE_ARCH('armv5tel'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
		values (LOOKUP_CHANNEL_ARCH('channel-armv5'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
        (LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-armv5'));
