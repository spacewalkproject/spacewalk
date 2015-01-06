insert into rhnChannelArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_channel_arch_id_seq'), 'channel-ppc64le', 'PPC64LE', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnChannelArch where label = 'channel-ppc64le');

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) select
LOOKUP_CHANNEL_ARCH('channel-ppc64le'), LOOKUP_PACKAGE_ARCH('noarch') from dual
where not exists (select 1 from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-ppc64le') and package_arch_id = LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnCpuArch (id, label, name) select
sequence_nextval('rhn_cpu_arch_id_seq'), 'ppc64le', 'ppc64le' from dual
where not exists (select 1 from rhnCpuArch where label = 'ppc64le');

insert into rhnPackageArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_package_arch_id_seq'), 'ppc64le', 'ppc64le', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnPackageArch where label = 'ppc64le');

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) select
LOOKUP_CHANNEL_ARCH('channel-ppc64le'), LOOKUP_PACKAGE_ARCH('ppc64le') from dual
where not exists (select 1 from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-ppc64le') and package_arch_id = LOOKUP_PACKAGE_ARCH('ppc64le'));

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc64le'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('ppc64le'));
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('ppc64le'), LOOKUP_PACKAGE_ARCH('ppc64le'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('ppc64le'));
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('ppc64le'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('ppc64le') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_server_arch_id_seq'), 'ppc64le-redhat-linux', 'ppc64le', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnServerArch where label = 'ppc64le-redhat-linux');

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) select
LOOKUP_SERVER_ARCH('ppc64le-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ppc64le') from dual
where not exists (select 1 from rhnServerChannelArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-ppc64le'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) select
LOOKUP_SERVER_ARCH('ppc64le-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64le'), 0 from dual
where not exists (select 1 from rhnServerPackageArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and package_arch_id = LOOKUP_PACKAGE_ARCH('ppc64le'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) select
LOOKUP_SERVER_ARCH('ppc64le-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000 from dual
where not exists (select 1 from rhnServerPackageArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and package_arch_id = LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('ppc64le-redhat-linux'), LOOKUP_SG_TYPE('sw_mgr_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
lookup_server_arch('ppc64le-redhat-linux'), lookup_sg_type('enterprise_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
lookup_server_arch('ppc64le-redhat-linux'), lookup_sg_type('provisioning_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
lookup_server_arch('ppc64le-redhat-linux'), lookup_sg_type('monitoring_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
lookup_server_arch('ppc64le-redhat-linux'), lookup_sg_type('virtualization_host') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('virtualization_host'));
