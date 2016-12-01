--
-- Copyright (c) 2008--2014 Red Hat, Inc.
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

insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'noarch', 'noarch', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'i386', 'i386', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'i486', 'i486', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'i586', 'i586', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'i686', 'i686', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'alpha', 'alpha', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'alphaev6', 'alphaev6', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ia64', 'ia64', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'sparc', 'sparc', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'sparcv9', 'sparcv9', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'sparc64', 'sparc64', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'src', 'src', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 's390', 's390', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'athlon', 'athlon', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 's390x', 's390x', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ppc', 'ppc', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ppc64', 'ppc64', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ppc64le', 'ppc64le', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'pSeries', 'pSeries', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'iSeries', 'iSeries', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'x86_64', 'x86_64', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ppc64iseries', 'ppc64iseries', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ppc64pseries', 'ppc64pseries', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'tar', 'TAR archive', lookup_arch_type('tar'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ia32e', 'EM64T', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'amd64', 'AMD64', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'aarch64', 'AArch64', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv7hnl', 'ARMv7hnl', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv7hl', 'ARMv7hl', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv7l', 'ARMv7l', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv6hl', 'ARMv6hl', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv6l', 'ARMv6l', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv5tel', 'ARMv5tel', lookup_arch_type('rpm'));

insert into rhnPackageArch (id, label, name, arch_type_id) values 
( sequence_nextval('rhn_package_arch_id_seq'), 'nosrc', 'nosrc', lookup_arch_type('rpm') );

insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'all-deb', 'all-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'i386-deb', 'i386-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'alpha-deb', 'alpha-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ia64-deb', 'ia64-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'sparc-deb', 'sparc-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'src-deb', 'src-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 's390-deb', 's390-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'powerpc-deb', 'powerpc-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'arm-deb', 'arm-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armhf-deb', 'armhf-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'mips-deb', 'mips-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'amd64-deb', 'AMD64-deb', lookup_arch_type('deb'));

commit;

