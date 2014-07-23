insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-ppc64le', 'PPC64LE', lookup_arch_type('rpm'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc64le'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc64le'), LOOKUP_PACKAGE_ARCH('ppc64le'));

insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'ppc64le', 'ppc64le');

insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ppc64le', 'ppc64le', lookup_arch_type('rpm'));

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc64le'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64le'), LOOKUP_PACKAGE_ARCH('ppc64le'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64le'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ppc64le-redhat-linux', 'ppc64le', lookup_arch_type('rpm'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('ppc64le-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ppc64le'));

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64le-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64le'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64le-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
    values (lookup_server_arch('ppc64le-redhat-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
    values (lookup_server_arch('ppc64le-redhat-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
    values (lookup_server_arch('ppc64le-redhat-linux'),
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
    values (lookup_server_arch('ppc64le-redhat-linux'),
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ppc64le-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
    values (lookup_server_arch('ppc64le-redhat-linux'),
            lookup_sg_type('bootstrap_entitled'));
