--
-- Copyright (c) 2010--2012 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation.
--
--
--

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386'), LOOKUP_PACKAGE_ARCH('i386'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('i386'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i486'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i486'), LOOKUP_PACKAGE_ARCH('i486'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('i486'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i586'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i586'), LOOKUP_PACKAGE_ARCH('i586'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('i586'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i686'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i686'), LOOKUP_PACKAGE_ARCH('i686'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('i686'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alpha'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alpha'), LOOKUP_PACKAGE_ARCH('alpha'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('alpha'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alphaev6'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alphaev6'), LOOKUP_PACKAGE_ARCH('alphaev6'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('alphaev6'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia64'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia64'), LOOKUP_PACKAGE_ARCH('ia64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ia64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc'), LOOKUP_PACKAGE_ARCH('sparc'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('sparc'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparcv9'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparcv9'), LOOKUP_PACKAGE_ARCH('sparcv9'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('sparcv9'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc64'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc64'), LOOKUP_PACKAGE_ARCH('sparc64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('sparc64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390'), LOOKUP_PACKAGE_ARCH('s390'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('s390'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('athlon'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('athlon'), LOOKUP_PACKAGE_ARCH('athlon'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('athlon'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390x'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390x'), LOOKUP_PACKAGE_ARCH('s390x'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('s390x'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc'), LOOKUP_PACKAGE_ARCH('ppc'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64'), LOOKUP_PACKAGE_ARCH('ppc64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('pSeries'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('pSeries'), LOOKUP_PACKAGE_ARCH('pSeries'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('pSeries'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('iSeries'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('iSeries'), LOOKUP_PACKAGE_ARCH('iSeries'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('iSeries'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('x86_64'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('x86_64'), LOOKUP_PACKAGE_ARCH('x86_64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('x86_64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64iseries'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64iseries'), LOOKUP_PACKAGE_ARCH('ppc64iseries'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc64iseries'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64pseries'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64pseries'), LOOKUP_PACKAGE_ARCH('ppc64pseries'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc64pseries'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('armv7l'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv7l'), LOOKUP_PACKAGE_ARCH('armv7l'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv7l'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('armv6l'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv6l'), LOOKUP_PACKAGE_ARCH('armv6l'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv6l'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('armv5tel'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv5tel'), LOOKUP_PACKAGE_ARCH('armv5tel'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv5tel'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('armv7hl'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv7hl'), LOOKUP_PACKAGE_ARCH('armv7hl'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv7hl'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('armv7hnl'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv7hnl'), LOOKUP_PACKAGE_ARCH('armv7hnl'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('armv7hnl'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('tar'), LOOKUP_PACKAGE_ARCH('tar'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia32e'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia32e'), LOOKUP_PACKAGE_ARCH('ia32e'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ia32e'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('amd64'), LOOKUP_PACKAGE_ARCH('noarch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('amd64'), LOOKUP_PACKAGE_ARCH('amd64'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('amd64'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alpha-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alpha-deb'), LOOKUP_PACKAGE_ARCH('alpha-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('alpha-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia64-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia64-deb'), LOOKUP_PACKAGE_ARCH('ia64-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('ia64-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-deb'), LOOKUP_PACKAGE_ARCH('sparc-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('sparc-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('src-deb'), LOOKUP_PACKAGE_ARCH('src-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390-deb'), LOOKUP_PACKAGE_ARCH('s390-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('s390-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('powerpc-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('powerpc-deb'), LOOKUP_PACKAGE_ARCH('powerpc-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('powerpc-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('arm-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('arm-deb'), LOOKUP_PACKAGE_ARCH('arm-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('arm-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('mips-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('mips-deb'), LOOKUP_PACKAGE_ARCH('mips-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('mips-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('amd64-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('amd64-deb'), LOOKUP_PACKAGE_ARCH('amd64-deb'), current_timestamp, current_timestamp);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('amd64-deb'), current_timestamp, current_timestamp);

