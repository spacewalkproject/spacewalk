--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_PACKAGE_ARCH('i386'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_PACKAGE_ARCH('i486'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_PACKAGE_ARCH('i586'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_PACKAGE_ARCH('i686'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_PACKAGE_ARCH('src'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_PACKAGE_ARCH('athlon'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_PACKAGE_ARCH('i386'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_PACKAGE_ARCH('i486'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_PACKAGE_ARCH('i586'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_PACKAGE_ARCH('i686'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_PACKAGE_ARCH('ia64'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_PACKAGE_ARCH('src'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-aarch64'), LOOKUP_PACKAGE_ARCH('aarch64'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-aarch64'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('armv7hl'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('armv7hnl'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv5tel'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv6hl'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv6l'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_PACKAGE_ARCH('armv7l'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_PACKAGE_ARCH('ia64-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_PACKAGE_ARCH('sparc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_PACKAGE_ARCH('sparcv9'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_PACKAGE_ARCH('sparc64'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_PACKAGE_ARCH('src'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-deb'), LOOKUP_PACKAGE_ARCH('sparc-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha'), LOOKUP_PACKAGE_ARCH('alpha'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha'), LOOKUP_PACKAGE_ARCH('alphaev6'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha'), LOOKUP_PACKAGE_ARCH('src'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha-deb'), LOOKUP_PACKAGE_ARCH('alpha-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390'), LOOKUP_PACKAGE_ARCH('s390'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390'), LOOKUP_PACKAGE_ARCH('src'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390-deb'), LOOKUP_PACKAGE_ARCH('s390-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390x'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390x'), LOOKUP_PACKAGE_ARCH('s390'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390x'), LOOKUP_PACKAGE_ARCH('s390x'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390x'), LOOKUP_PACKAGE_ARCH('src'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-iSeries'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-iSeries'), LOOKUP_PACKAGE_ARCH('s390x'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-iSeries'), LOOKUP_PACKAGE_ARCH('ppc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-iSeries'), LOOKUP_PACKAGE_ARCH('ppc64'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-iSeries'), LOOKUP_PACKAGE_ARCH('src'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-pSeries'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-pSeries'), LOOKUP_PACKAGE_ARCH('ppc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-pSeries'), LOOKUP_PACKAGE_ARCH('ppc64'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-pSeries'), LOOKUP_PACKAGE_ARCH('src'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('i386'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('i486'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('i586'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('i686'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('athlon'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('ia32e'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('amd64'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('x86_64'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('src'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_PACKAGE_ARCH('all-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_PACKAGE_ARCH('i386-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_PACKAGE_ARCH('amd64-deb'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_PACKAGE_ARCH('src-deb'));


insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc'), LOOKUP_PACKAGE_ARCH('noarch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc'), LOOKUP_PACKAGE_ARCH('ppc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc'), LOOKUP_PACKAGE_ARCH('ppc64'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc'), LOOKUP_PACKAGE_ARCH('ppc64iseries'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc'), LOOKUP_PACKAGE_ARCH('ppc64pseries'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc'), LOOKUP_PACKAGE_ARCH('src'));

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

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4u-solaris'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_PACKAGE_ARCH('sparc.sun4v-solaris'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_PACKAGE_ARCH('sparc-solaris-patch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390x'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-iSeries'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-pSeries'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc'), LOOKUP_PACKAGE_ARCH('nosrc'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch-cluster'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_PACKAGE_ARCH('i386-solaris-patch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'));

insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'));

commit;
