--
-- Add new rows for debian support
--


insert into rhnArchType (id, label, name) values
	(rhn_archtype_id_seq.nextval, 'deb', 'DEB');

commit;

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-ia32-deb', 'IA-32 Debian', lookup_arch_type('deb'));
insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-ia64-deb', 'IA-64 Debian', lookup_arch_type('deb'));
insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-amd64-deb', 'AMD64 Debian', lookup_arch_type('deb'));
insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-sparc-deb', 'Sparc Debian', lookup_arch_type('deb'));
insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-alpha-deb', 'Alpha Debian', lookup_arch_type('deb'));
insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-s390-deb', 's390 Debian', lookup_arch_type('deb'));
insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-powerpc-deb', 'PowerPC Debian', lookup_arch_type('deb'));
insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-arm-deb', 'arm Debian', lookup_arch_type('deb'));
insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-mips-deb', 'mips Debian', lookup_arch_type('deb'));

commit;

insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'all-deb', 'all-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'i386-deb', 'i386-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'alpha-deb', 'alpha-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'ia64-deb', 'ia64-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'sparc-deb', 'sparc-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'src-deb', 'src-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 's390-deb', 's390-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'powerpc-deb', 'powerpc-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'arm-deb', 'arm-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'mips-deb', 'mips-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(rhn_package_arch_id_seq.nextval, 'amd64-deb', 'AMD64-deb', lookup_arch_type('deb'));

commit;

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_PACKAGE_ARCH('ia64-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-deb'), LOOKUP_PACKAGE_ARCH('sparc-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha-deb'), LOOKUP_PACKAGE_ARCH('alpha-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390-deb'), LOOKUP_PACKAGE_ARCH('s390-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_PACKAGE_ARCH('amd64-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-powerpc-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-powerpc-deb'), LOOKUP_PACKAGE_ARCH('powerpc-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-powerpc-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm-deb'), LOOKUP_PACKAGE_ARCH('arm-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-mips-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-mips-deb'), LOOKUP_PACKAGE_ARCH('mips-deb'));
insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-mips-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

commit;


insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'i386-debian-linux', 'i386 Debian', lookup_arch_type('deb'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'alpha-debian-linux', 'alpha Debian', lookup_arch_type('deb'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'ia64-debian-linux', 'ia64 Debian', lookup_arch_type('deb'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'sparc-debian-linux', 'sparc Debian', lookup_arch_type('deb'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 's390-debian-linux', 's390 Debian', lookup_arch_type('deb'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'powerpc-debian-linux', 'powerpc Debian', lookup_arch_type('deb'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'amd64-debian-linux', 'AMD64 Debian', lookup_arch_type('deb'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'arm-debian-linux', 'arm Debian', lookup_arch_type('deb'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'mips-debian-linux', 'mips Debian', lookup_arch_type('deb'));

commit;

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('i386-debian-linux'), LOOKUP_PACKAGE_ARCH('i386-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('i386-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('alpha-debian-linux'), LOOKUP_PACKAGE_ARCH('alpha-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('alpha-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('ia64-debian-linux'), LOOKUP_PACKAGE_ARCH('ia64-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('ia64-debian-linux'), LOOKUP_PACKAGE_ARCH('i386-deb'), 100);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('ia64-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('sparc-debian-linux'), LOOKUP_PACKAGE_ARCH('sparc-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('sparc-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('s390-debian-linux'), LOOKUP_PACKAGE_ARCH('s390-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('s390-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('powerpc-debian-linux'), LOOKUP_PACKAGE_ARCH('powerpc-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('powerpc-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('arm-debian-linux'), LOOKUP_PACKAGE_ARCH('arm-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('arm-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('mips-debian-linux'), LOOKUP_PACKAGE_ARCH('mips-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('mips-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('amd64-debian-linux'), LOOKUP_PACKAGE_ARCH('amd64-deb'), 0);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('amd64-debian-linux'), LOOKUP_PACKAGE_ARCH('i386-deb'), 140);
insert into rhnServerPackageArchCompat
 (server_arch_id, package_arch_id, preference) values
 (LOOKUP_SERVER_ARCH('amd64-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

commit;

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('i386-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-ia32-deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('alpha-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-alpha-deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('ia64-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-ia64-deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('sparc-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-sparc-deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('s390-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-s390-deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('powerpc-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-powerpc-deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('amd64-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-amd64-deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('arm-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-arm-deb'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('mips-debian-linux'), LOOKUP_CHANNEL_ARCH('channel-mips-deb'));

commit;

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('arm-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('mips-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-debian-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-debian-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('arm-debian-linux'),
            lookup_sg_type('enterprise_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('mips-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-debian-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-debian-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('arm-debian-linux'),
            lookup_sg_type('provisioning_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('mips-debian-linux'),
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-debian-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-debian-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('arm-debian-linux'),
            lookup_sg_type('monitoring_entitled'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('mips-debian-linux'),
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('virtualization_host'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('virtualization_host'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('virtualization_host'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('virtualization_host'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('virtualization_host_platform'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('virtualization_host_platform'));
insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('virtualization_host_platform'));

commit;
