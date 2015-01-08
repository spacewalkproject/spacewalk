insert into rhnChannelArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_channel_arch_id_seq'), 'channel-armhfp', 'ARM hard. FP', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnChannelArch where label = 'channel-armhfp');

insert into rhnPackageArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_package_arch_id_seq'), 'armv7hnl', 'ARMv7hnl', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnPackageArch where label = 'armv7hnl');
insert into rhnPackageArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_package_arch_id_seq'), 'armv7hl', 'ARMv7hl', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnPackageArch where label = 'armv7hl');

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) select
LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('armv7hnl') from dual
where not exists (select 1 from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-armhfp') and package_arch_id = LOOKUP_PACKAGE_ARCH('armv7hnl'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) select
LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('armv7hl') from dual
where not exists (select 1 from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-armhfp') and package_arch_id = LOOKUP_PACKAGE_ARCH('armv7hnl'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) select
LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('noarch') from dual
where not exists (select 1 from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-armhfp') and package_arch_id = LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnServerArch (id, label, name, arch_type_id) select
sequence_nextval('rhn_server_arch_id_seq'), 'armv7l-redhat-linux', 'armv7l', lookup_arch_type('rpm') from dual
where not exists (select 1 from rhnServerArch where label = 'armv7l-redhat-linux');

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) select
LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-armhfp') from dual
where not exists (select 1 from rhnServerChannelArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv7l-redhat-linux') and channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-armhfp'));


insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_SG_TYPE('sw_mgr_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv7l-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_SG_TYPE('enterprise_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv7l-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_SG_TYPE('provisioning_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv7l-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_SG_TYPE('monitoring_entitled') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv7l-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_SG_TYPE('virtualization_host') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('armv7l-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('virtualization_host'));

insert into rhnCpuArch (id, label, name) select
sequence_nextval('rhn_cpu_arch_id_seq'), 'armv7l', 'ARMv7l' from dual
where not exists (select 1 from rhnCpuArch where label = 'armv7l');
