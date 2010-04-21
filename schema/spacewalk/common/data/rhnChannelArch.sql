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

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-ia32', 'IA-32', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-ia32-deb', 'IA-32 Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-ia64', 'IA-64', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-ia64-deb', 'IA-64 Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-sparc', 'Sparc', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-sparc-deb', 'Sparc Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-alpha', 'Alpha', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-alpha-deb', 'Alpha Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-s390', 's390', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-s390-deb', 's390 Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-s390x', 's390x', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-iSeries', 'iSeries', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-pSeries', 'pSeries', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-x86_64', 'x86_64', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-amd64-deb', 'AMD64 Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-ppc', 'PPC', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-powerpc-deb', 'PowerPC Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-arm-deb', 'arm Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-mips-deb', 'mips Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-sparc-sun-solaris', 'Sparc Solaris', lookup_arch_type('sysv-solaris'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(rhn_channel_arch_id_seq.nextval, 'channel-i386-sun-solaris', 'i386 Solaris', lookup_arch_type('sysv-solaris'));

commit;

--
-- Revision 1.11  2004/02/19 17:40:28  misa
-- Solaris patches
--
-- Revision 1.10  2004/02/19 00:13:11  pjones
-- bugzilla: 116188 -- ia32e/amd64 support that might actually work.
--
-- Revision 1.9  2004/02/06 02:21:16  misa
-- Weird solaris arches added
--
-- Revision 1.8  2004/02/05 17:33:12  pjones
-- bugzilla: 115009 -- rhnArchType is new, and has changes to go with it
--
-- Revision 1.7  2003/10/06 14:38:07  cturner
-- make the Name column more representative of proper noun usage of arches
--
-- Revision 1.6  2003/06/09 18:16:04  misa
-- bugzilla: 86150  Added the ppc64iseries and ppc64pseries arches, plus the channel-ppc channel arch
--
-- Revision 1.5  2003/01/29 17:11:36  misa
-- bugzilla: 83022  Adding x86_64 as a supported arch
--
-- Revision 1.4  2002/11/13 22:59:59  misa
-- Added a sequence; added data
--
-- Revision 1.3  2002/11/13 00:22:11  misa
-- name -> label
-- the label becomes family_blah
--
-- Revision 1.2  2002/11/12 23:36:21  misa
-- Added rhnArchFamily and rhnArchFamilyMembers
--
-- Revision 1.1  2002/10/15 21:06:22  misa
-- Arch family
--
