--
-- Copyright (c) 2008 Red Hat, Inc.
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
--

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-debian-linux'), LOOKUP_PACKAGE_ARCH('i386-deb'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i486-redhat-linux'), LOOKUP_PACKAGE_ARCH('i486'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i486-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i486-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i586-redhat-linux'), LOOKUP_PACKAGE_ARCH('i586'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i586-redhat-linux'), LOOKUP_PACKAGE_ARCH('i486'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i586-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i586-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i686-redhat-linux'), LOOKUP_PACKAGE_ARCH('i686'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i686-redhat-linux'), LOOKUP_PACKAGE_ARCH('i586'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i686-redhat-linux'), LOOKUP_PACKAGE_ARCH('i486'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i686-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 30);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i686-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);


insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('athlon-redhat-linux'), LOOKUP_PACKAGE_ARCH('athlon'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('athlon-redhat-linux'), LOOKUP_PACKAGE_ARCH('i686'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('athlon-redhat-linux'), LOOKUP_PACKAGE_ARCH('i586'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('athlon-redhat-linux'), LOOKUP_PACKAGE_ARCH('i486'), 30);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('athlon-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 40);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('athlon-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('alpha-redhat-linux'), LOOKUP_PACKAGE_ARCH('alpha'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('alpha-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('alpha-debian-linux'), LOOKUP_PACKAGE_ARCH('alpha-deb'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('alpha-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('alphaev6-redhat-linux'), LOOKUP_PACKAGE_ARCH('alphaev6'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('alphaev6-redhat-linux'), LOOKUP_PACKAGE_ARCH('alpha'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('alphaev6-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia64-redhat-linux'), LOOKUP_PACKAGE_ARCH('ia64'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 100);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i486'), 200);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i586'), 300);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i686'), 400);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia64-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

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
(LOOKUP_SERVER_ARCH('sparc-redhat-linux'), LOOKUP_PACKAGE_ARCH('sparc'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-debian-linux'), LOOKUP_PACKAGE_ARCH('sparc-deb'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparcv9-redhat-linux'), LOOKUP_PACKAGE_ARCH('sparcv9'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparcv9-redhat-linux'), LOOKUP_PACKAGE_ARCH('sparc'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparcv9-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc64-redhat-linux'), LOOKUP_PACKAGE_ARCH('sparc64'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc64-redhat-linux'), LOOKUP_PACKAGE_ARCH('sparcv9'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc64-redhat-linux'), LOOKUP_PACKAGE_ARCH('sparc'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc64-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('s390-redhat-linux'), LOOKUP_PACKAGE_ARCH('s390'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('s390-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('s390-debian-linux'), LOOKUP_PACKAGE_ARCH('s390-deb'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('s390-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('s390x-redhat-linux'), LOOKUP_PACKAGE_ARCH('s390x'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('s390x-redhat-linux'), LOOKUP_PACKAGE_ARCH('s390'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('s390x-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);


insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

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
(LOOKUP_SERVER_ARCH('ppc64-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('pSeries-redhat-linux'), LOOKUP_PACKAGE_ARCH('pSeries'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('pSeries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('pSeries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('pSeries-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('iSeries-redhat-linux'), LOOKUP_PACKAGE_ARCH('iSeries'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('iSeries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('iSeries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('iSeries-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('x86_64-redhat-linux'), LOOKUP_PACKAGE_ARCH('x86_64'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('x86_64-redhat-linux'), LOOKUP_PACKAGE_ARCH('athlon'), 100);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('x86_64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i686'), 110);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('x86_64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i586'), 120);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('x86_64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i486'), 130);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('x86_64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 140);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('x86_64-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_PACKAGE_ARCH('amd64'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_PACKAGE_ARCH('x86_64'), 50);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_PACKAGE_ARCH('athlon'), 100);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i686'), 110);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i586'), 120);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i486'), 130);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 140);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-debian-linux'), LOOKUP_PACKAGE_ARCH('amd64-deb'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-debian-linux'), LOOKUP_PACKAGE_ARCH('i386-deb'), 140);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('amd64-debian-linux'), LOOKUP_PACKAGE_ARCH('all-deb'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_PACKAGE_ARCH('ia32e'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_PACKAGE_ARCH('x86_64'), 50);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_PACKAGE_ARCH('athlon'), 100);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_PACKAGE_ARCH('i686'), 110);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_PACKAGE_ARCH('i586'), 120);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_PACKAGE_ARCH('i486'), 130);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_PACKAGE_ARCH('i386'), 140);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);


insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64iseries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64iseries'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64iseries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64iseries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64iseries-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64pseries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64pseries'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64pseries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc64'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64pseries-redhat-linux'), LOOKUP_PACKAGE_ARCH('ppc'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('ppc64pseries-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), 100);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris'), 210);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), 310);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), 410);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), 510);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), 610);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), 710); 

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris'), 100);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), 210);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), 310);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), 410);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), 510);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), 610); 

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4v-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4v-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris'), 100);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4v-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'), 210);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4v-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'), 310);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4v-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), 410);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4v-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), 510);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4v-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), 610);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-i86pc-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-i86pc-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch'), 200);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-i86pc-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'), 300);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-i86pc-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), 410);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-i86pc-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), 510);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('i386-i86pc-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), 610);


commit;

--
-- Revision 1.10  2004/02/19 00:13:11  pjones
-- bugzilla: 116188 -- ia32e/amd64 support that might actually work.
--
-- Revision 1.9  2004/02/18 23:41:04  pjones
-- bugzilla: 116188 -- ia32e
--
-- Revision 1.8  2004/02/13 14:38:50  misa
-- bugzilla: 115516  Arches and compat stuff for solaris patches
--
-- Revision 1.7  2004/02/06 02:21:16  misa
-- Weird solaris arches added
--
-- Revision 1.6  2003/07/23 18:47:53  misa
-- bugzilla: none  More compat mappings for ia64
--
-- Revision 1.5  2003/06/09 18:16:04  misa
-- bugzilla: 86150  Added the ppc64iseries and ppc64pseries arches, plus the channel-ppc channel arch
--
-- Revision 1.4  2003/01/29 17:52:22  misa
-- bugzilla: 78615  Re-generated the arch compat tables from webdev
--
-- Revision 1.3  2003/01/29 17:11:37  misa
-- bugzilla: 83022  Adding x86_64 as a supported arch
--
-- Revision 1.2  2002/11/14 18:00:59  pjones
-- commits
--
-- Revision 1.1  2002/11/14 01:06:09  misa
-- Populating the table
--
