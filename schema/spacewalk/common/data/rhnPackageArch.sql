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
(sequence_nextval('rhn_package_arch_id_seq'), 'sparc-solaris', 'Sparc Solaris', lookup_arch_type('sysv-solaris'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'sparc.sun4u-solaris', 'Sparc Solaris sun4u', lookup_arch_type('sysv-solaris'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'sparc.sun4v-solaris', 'Sparc Solaris sun4v', lookup_arch_type('sysv-solaris'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'tar', 'TAR archive', lookup_arch_type('tar'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'ia32e', 'EM64T', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'amd64', 'AMD64', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'i386-solaris', 'i386-solaris', lookup_arch_type('sysv-solaris'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv7hnl', 'ARMv7hnl', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv7hl', 'ARMv7hl', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv7l', 'ARMv7l', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv6l', 'ARMv6l', lookup_arch_type('rpm'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'armv5tel', 'ARMv5tel', lookup_arch_type('rpm'));

insert into rhnPackageArch (id, label, name, arch_type_id) values 
( sequence_nextval('rhn_package_arch_id_seq'), 'nosrc', 'nosrc', lookup_arch_type('rpm') );


insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'sparc-solaris-patch', 'Sparc Solaris patch', lookup_arch_type('solaris-patch'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'i386-solaris-patch', 'i386 Solaris patch', lookup_arch_type('solaris-patch'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'sparc-solaris-patch-cluster',
'Sparc Solaris patch cluster', lookup_arch_type('solaris-patch-cluster'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'i386-solaris-patch-cluster',
'i386 Solaris patch cluster', lookup_arch_type('solaris-patch-cluster'));
 
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'noarch-solaris', 'noarch-solaris', lookup_arch_type('sysv-solaris'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'noarch-solaris-patch', 'noarch-solaris-patch', lookup_arch_type('sysv-solaris'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'noarch-solaris-patch-cluster', 'noarch-solaris-patch-cluster', lookup_arch_type('sysv-solaris'));

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
(sequence_nextval('rhn_package_arch_id_seq'), 'mips-deb', 'mips-deb', lookup_arch_type('deb'));
insert into rhnPackageArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_package_arch_id_seq'), 'amd64-deb', 'AMD64-deb', lookup_arch_type('deb'));

commit;

--
-- Revision 1.10  2004/05/11 18:29:40  pjones
-- bugzilla: none -- make EM64T and AMD64 registerable as such, and fix their
-- names while I'm at it.
--
-- Revision 1.9  2004/02/18 23:41:04  pjones
-- bugzilla: 116188 -- ia32e
--
-- Revision 1.8  2004/02/16 16:38:26  rnorwood
-- bugzilla: 115111 - package arch data for solaris-patch-cluster.
--
-- Revision 1.7  2004/02/13 14:38:50  misa
-- bugzilla: 115516  Arches and compat stuff for solaris patches
--
-- Revision 1.6  2004/02/06 02:21:16  misa
-- Weird solaris arches added
--
-- Revision 1.5  2004/02/05 17:33:12  pjones
-- bugzilla: 115009 -- rhnArchType is new, and has changes to go with it
--
-- Revision 1.4  2003/06/09 18:16:04  misa
-- bugzilla: 86150  Added the ppc64iseries and ppc64pseries arches, plus the channel-ppc channel arch
--
-- Revision 1.3  2003/01/29 17:11:36  misa
-- bugzilla: 83022  Adding x86_64 as a supported arch
--
-- Revision 1.2  2002/11/14 18:00:59  pjones
-- commits
--
-- Revision 1.1  2002/11/13 23:42:28  misa
-- Sequence; data to populate stuff
--

