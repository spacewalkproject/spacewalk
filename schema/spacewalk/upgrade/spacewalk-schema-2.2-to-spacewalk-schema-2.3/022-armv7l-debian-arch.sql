insert into rhnServerArch (id, label, name, arch_type_id) values (sequence_nextval('rhn_server_arch_id_seq'), 'armv7l-debian-linux', 'arm Debian', lookup_arch_type('deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values (LOOKUP_SERVER_ARCH('armv7l-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-arm-deb'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) values (LOOKUP_SERVER_ARCH('armv7l-debian-linux'), LOOKUP_PACKAGE_ARCH('armhf-deb'), 0);

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type ) values (lookup_server_arch('armv7l-debian-linux'), lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type ) values (lookup_server_arch('armv7l-debian-linux'), lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type ) values (lookup_server_arch('armv7l-debian-linux'), lookup_sg_type('provisioning_entitled'));
