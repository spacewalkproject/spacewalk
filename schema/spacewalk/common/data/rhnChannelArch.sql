--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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
--
-- Please note when adding new architectures also update the file
-- StringResource_*.xml (search for rhnChannelArch.sql comment).

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-ia32', 'IA-32', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-ia32-deb', 'IA-32 Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-ia64', 'IA-64', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-ia64-deb', 'IA-64 Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-sparc', 'Sparc', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-sparc-deb', 'Sparc Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-alpha', 'Alpha', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-alpha-deb', 'Alpha Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-s390', 's390', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-s390-deb', 's390 Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-s390x', 's390x', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-iSeries', 'iSeries', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-pSeries', 'pSeries', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-x86_64', 'x86_64', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-amd64-deb', 'AMD64 Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-ppc', 'PPC', lookup_arch_type('rpm'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-powerpc-deb', 'PowerPC Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-arm-deb', 'arm Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-mips-deb', 'mips Debian', lookup_arch_type('deb'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-sparc-sun-solaris', 'Sparc Solaris', lookup_arch_type('sysv-solaris'));

insert into rhnChannelArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_channel_arch_id_seq'), 'channel-i386-sun-solaris', 'i386 Solaris', lookup_arch_type('sysv-solaris'));

commit;

