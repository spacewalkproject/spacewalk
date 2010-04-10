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

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('i386-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ia32'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('i486-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ia32'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('i586-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ia32'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('i686-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ia32'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('athlon-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ia32'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('alpha-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-alpha'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('alphaev6-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-alpha'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('ia64-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ia64'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('sparc-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-sparc'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('sparcv9-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-sparc'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('sparc64-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-sparc'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('s390-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-s390'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('s390x-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-s390x'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('pSeries-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-pSeries'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('iSeries-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-iSeries'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('x86_64-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-x86_64'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('ia32e-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-x86_64'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('amd64-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-x86_64'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('ppc64iseries-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ppc'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('ppc64pseries-redhat-linux'), LOOKUP_CHANNEL_ARCH('channel-ppc'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('sparc-sun4m-solaris'), LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('sparc-sun4v-solaris'), LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'));

insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) values
(LOOKUP_SERVER_ARCH('i386-i86pc-solaris'), LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'));

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

--
-- Revision 1.10  2004/02/19 17:40:28  misa
-- Solaris patches
--
-- Revision 1.9  2004/02/19 00:13:11  pjones
-- bugzilla: 116188 -- ia32e/amd64 support that might actually work.
--
-- Revision 1.8  2004/02/18 23:41:04  pjones
-- bugzilla: 116188 -- ia32e
--
-- Revision 1.7  2004/02/06 02:21:16  misa
-- Weird solaris arches added
--
-- Revision 1.6  2003/06/09 18:16:04  misa
-- bugzilla: 86150  Added the ppc64iseries and ppc64pseries arches, plus the channel-ppc channel arch
--
-- Revision 1.5  2003/01/29 17:52:22  misa
-- bugzilla: 78615  Re-generated the arch compat tables from webdev
--
-- Revision 1.4  2003/01/29 17:11:36  misa
-- bugzilla: 83022  Adding x86_64 as a supported arch
--
-- Revision 1.3  2002/11/14 18:00:59  pjones
-- commits
--
-- Revision 1.2  2002/11/14 16:26:05  misa
-- Populating the table
--
-- Revision 1.1  2002/11/14 00:36:27  misa
-- Added data to rhnServerChannelArchCompat data
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
