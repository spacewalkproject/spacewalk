delete from rhnChildChannelArchCompat where parent_arch_id = LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris');
delete from rhnChildChannelArchCompat where parent_arch_id = LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris');

delete from rhnChildChannelArchCompat where child_arch_id = LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris');
delete from rhnChildChannelArchCompat where child_arch_id = LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris');

delete from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris');
delete from rhnChannelPackageArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris');

delete from rhnServerChannelArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris');
delete from rhnServerChannelArchCompat where channel_arch_id = LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris');

delete from rhnChannelArch where label = 'channel-sparc-sun-solaris';
delete from rhnChannelArch where label = 'channel-i386-sun-solaris';

delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster');

delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch');
delete from rhnPackageUpgradeArchCompat where package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster');

delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch');
delete from rhnServerPackageArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster');

delete from rhnPackageArch where label = 'sparc-solaris';
delete from rhnPackageArch where label = 'sparc.sun4u-solaris';
delete from rhnPackageArch where label = 'sparc.sun4v-solaris';
delete from rhnPackageArch where label = 'i386-solaris';
delete from rhnPackageArch where label = 'sparc-solaris-patch';
delete from rhnPackageArch where label = 'i386-solaris-patch';
delete from rhnPackageArch where label = 'sparc-solaris-patch-cluster';
delete from rhnPackageArch where label = 'i386-solaris-patch-cluster';
delete from rhnPackageArch where label = 'noarch-solaris';
delete from rhnPackageArch where label = 'noarch-solaris-patch';
delete from rhnPackageArch where label = 'noarch-solaris-patch-cluster';

delete from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4m-solaris');
delete from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4u-solaris');
delete from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4v-solaris');
delete from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('i386-i86pc-solaris');

delete from rhnServerArch where label = 'sparc-sun4m-solaris';
delete from rhnServerArch where label = 'sparc-sun4u-solaris';
delete from rhnServerArch where label = 'sparc-sun4v-solaris';
delete from rhnServerArch where label = 'i386-i86pc-solaris';

delete from rhnArchType where label = 'solaris-patch';
delete from rhnArchType where label = 'solaris-patch-cluster';
delete from rhnArchType where label = 'sysv-solaris';
