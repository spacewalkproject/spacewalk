--
-- Copyright (c) 2010 Red Hat, Inc.
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

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386'), LOOKUP_PACKAGE_ARCH('i386'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('i386'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i486'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i486'), LOOKUP_PACKAGE_ARCH('i486'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('i486'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i586'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i586'), LOOKUP_PACKAGE_ARCH('i586'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('i586'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i686'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i686'), LOOKUP_PACKAGE_ARCH('i686'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('i686'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alpha'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alpha'), LOOKUP_PACKAGE_ARCH('alpha'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('alpha'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alphaev6'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alphaev6'), LOOKUP_PACKAGE_ARCH('alphaev6'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('alphaev6'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia64'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia64'), LOOKUP_PACKAGE_ARCH('ia64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ia64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc'), LOOKUP_PACKAGE_ARCH('sparc'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('sparc'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparcv9'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparcv9'), LOOKUP_PACKAGE_ARCH('sparcv9'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('sparcv9'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc64'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc64'), LOOKUP_PACKAGE_ARCH('sparc64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('sparc64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390'), LOOKUP_PACKAGE_ARCH('s390'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('s390'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('athlon'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('athlon'), LOOKUP_PACKAGE_ARCH('athlon'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('athlon'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390x'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390x'), LOOKUP_PACKAGE_ARCH('s390x'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('s390x'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc'), LOOKUP_PACKAGE_ARCH('ppc'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64'), LOOKUP_PACKAGE_ARCH('ppc64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('pSeries'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('pSeries'), LOOKUP_PACKAGE_ARCH('pSeries'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('pSeries'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('iSeries'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('iSeries'), LOOKUP_PACKAGE_ARCH('iSeries'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('iSeries'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('x86_64'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('x86_64'), LOOKUP_PACKAGE_ARCH('x86_64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('x86_64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64iseries'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64iseries'), LOOKUP_PACKAGE_ARCH('ppc64iseries'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc64iseries'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64pseries'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ppc64pseries'), LOOKUP_PACKAGE_ARCH('ppc64pseries'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ppc64pseries'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('tar'), LOOKUP_PACKAGE_ARCH('tar'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia32e'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia32e'), LOOKUP_PACKAGE_ARCH('ia32e'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('ia32e'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('amd64'), LOOKUP_PACKAGE_ARCH('noarch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('amd64'), LOOKUP_PACKAGE_ARCH('amd64'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch'), LOOKUP_PACKAGE_ARCH('amd64'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);

insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('i386-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alpha-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('alpha-deb'), LOOKUP_PACKAGE_ARCH('alpha-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('alpha-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia64-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('ia64-deb'), LOOKUP_PACKAGE_ARCH('ia64-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('ia64-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('sparc-deb'), LOOKUP_PACKAGE_ARCH('sparc-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('sparc-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('src-deb'), LOOKUP_PACKAGE_ARCH('src-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('s390-deb'), LOOKUP_PACKAGE_ARCH('s390-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('s390-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('powerpc-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('powerpc-deb'), LOOKUP_PACKAGE_ARCH('powerpc-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('powerpc-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('arm-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('arm-deb'), LOOKUP_PACKAGE_ARCH('arm-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('arm-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('mips-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('mips-deb'), LOOKUP_PACKAGE_ARCH('mips-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('mips-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('amd64-deb'), LOOKUP_PACKAGE_ARCH('all-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('amd64-deb'), LOOKUP_PACKAGE_ARCH('amd64-deb'), sysdate, sysdate);
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) values (LOOKUP_PACKAGE_ARCH('all-deb'), LOOKUP_PACKAGE_ARCH('amd64-deb'), sysdate, sysdate);

