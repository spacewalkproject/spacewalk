insert into rhnChannelArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_channel_arch_id_seq'), 'channel-aarch64', 'AArch64', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnChannelArch where label = 'channel-aarch64');

insert into rhnPackageArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_package_arch_id_seq'), 'aarch64', 'AArch64', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnPackageArch where label ='aarch64');

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) select
LOOKUP_CHANNEL_ARCH('channel-aarch64'), LOOKUP_PACKAGE_ARCH('aarch64') from dual
where not exists (select 1 from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-aarch64') and package_arch_id = LOOKUP_PACKAGE_ARCH('aarch64'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) select
LOOKUP_CHANNEL_ARCH('channel-aarch64'), LOOKUP_PACKAGE_ARCH('noarch') from dual
where not exists (select 1 from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-aarch64') and package_arch_id = LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_server_arch_id_seq'), 'aarch64-redhat-linux', 'aarch64', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnServerArch where label = 'aarch64-redhat-linux');

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('aarch64'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('aarch64'));
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('aarch64'), LOOKUP_PACKAGE_ARCH('aarch64'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('aarch64') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('aarch64'));
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('aarch64'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('aarch64') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) select
LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-aarch64') from dual
where not exists (select 1 from rhnServerChannelArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('aarch64-redhat-linux') and channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-aarch64'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) select
LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_PACKAGE_ARCH('aarch64'), 0 from dual
where not exists (select 1 from rhnServerPackageArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('aarch64-redhat-linux') and package_arch_id = LOOKUP_PACKAGE_ARCH('aarch64'));


insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_SG_TYPE('sw_mgr_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('aarch64-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_SG_TYPE('enterprise_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('aarch64-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_SG_TYPE('provisioning_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('aarch64-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_SG_TYPE('monitoring_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('aarch64-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_SG_TYPE('virtualization_host') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('aarch64-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('virtualization_host'));

insert into rhnCpuArch (id, label, name) select
sequence_nextval('rhn_cpu_arch_id_seq'), 'aarch64', 'AArch64' from dual
where not exists (select 1 from rhnCpuArch where label = 'aarch64');
