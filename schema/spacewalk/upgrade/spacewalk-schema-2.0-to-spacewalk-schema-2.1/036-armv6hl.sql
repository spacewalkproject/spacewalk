insert into rhnCpuArch (id, label, name) select
sequence_nextval('rhn_cpu_arch_id_seq'), 'armv6hl', 'ARMv6hl' from dual
where not exists (select 1 from rhnCpuArch where label = 'armv6hl');


insert into rhnPackageArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_package_arch_id_seq'), 'armv6hl', 'ARMv6hl', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnPackageArch where label = 'armv6hl');


insert into rhnServerArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_server_arch_id_seq'), 'armv6hl-redhat-linux', 'armv6hl', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnServerArch where label = 'armv6hl-redhat-linux');


insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('armv6hl'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('armv6hl'));

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('armv6hl'), LOOKUP_PACKAGE_ARCH('armv6hl'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('armv6hl') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('armv6hl'));

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('armv6hl'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('armv6hl') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) select
LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv6hl') from dual
where not exists (select 1 from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-arm') and package_arch_id = LOOKUP_PACKAGE_ARCH('armv6hl'));


insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) select
LOOKUP_SERVER_ARCH('armv6hl-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-arm') from dual
where not exists (select 1 from rhnServerChannelArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv6hl-redhat-linux') and channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-arm'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) select
LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv6hl'), 25 from dual
where not exists (select 1 from rhnServerPackageArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv7l-redhat-linux') and package_arch_id = LOOKUP_PACKAGE_ARCH('armv6hl'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) select
LOOKUP_SERVER_ARCH('armv6hl-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv6hl'), 0 from dual
where not exists (select 1 from rhnServerPackageArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv6hl-redhat-linux'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) select
LOOKUP_SERVER_ARCH('armv6hl-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv6l'), 10 from dual
where not exists (select 1 from rhnServerPackageArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv6hl-redhat-linux') and package_arch_id = LOOKUP_PACKAGE_ARCH('armv6l'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) select
LOOKUP_SERVER_ARCH('armv6hl-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv5tel'), 20 from dual
where not exists (select 1 from rhnServerPackageArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv6hl-redhat-linux') and package_arch_id = LOOKUP_PACKAGE_ARCH('armv5tel'));

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) select
LOOKUP_SERVER_ARCH('armv6hl-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000 from dual
where not exists (select 1 from rhnServerPackageArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv6hl-redhat-linux') and package_arch_id = LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type ) select
lookup_server_arch('armv6hl-redhat-linux'), lookup_sg_type('sw_mgr_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = lookup_server_arch('armv6hl-redhat-linux') and server_group_type = lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type ) select
lookup_server_arch('armv6hl-redhat-linux'), lookup_sg_type('enterprise_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = lookup_server_arch('armv6hl-redhat-linux') and server_group_type = lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type ) select
lookup_server_arch('armv6hl-redhat-linux'), lookup_sg_type('provisioning_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = lookup_server_arch('armv6hl-redhat-linux') and server_group_type = lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type ) select
lookup_server_arch('armv6hl-redhat-linux'), lookup_sg_type('monitoring_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = lookup_server_arch('armv6hl-redhat-linux') and server_group_type = lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type ) select
lookup_server_arch('armv6hl-redhat-linux'), lookup_sg_type('virtualization_host') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = lookup_server_arch('armv6hl-redhat-linux') and server_group_type = lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type ) select
lookup_server_arch('armv6hl-redhat-linux'), lookup_sg_type('virtualization_host_platform') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = lookup_server_arch('armv6hl-redhat-linux') and server_group_type = lookup_sg_type('virtualization_host_platform'));
