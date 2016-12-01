--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'i386-redhat-linux', 'i386', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'i386-debian-linux', 'i386 Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'i486-redhat-linux', 'i486', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'i586-redhat-linux', 'i586', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'i686-redhat-linux', 'i686', lookup_arch_type('rpm'));


insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'athlon-redhat-linux', 'athlon', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'alpha-redhat-linux', 'alpha', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'alpha-debian-linux', 'alpha Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'alphaev6-redhat-linux', 'alphaev6', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ia64-redhat-linux', 'ia64', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ia64-debian-linux', 'ia64 Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'sparc-redhat-linux', 'sparc', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'sparc-debian-linux', 'sparc Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'sparcv9-redhat-linux', 'sparcv9', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'sparc64-redhat-linux', 'sparc64', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 's390-redhat-linux', 's390', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 's390-debian-linux', 's390 Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 's390x-redhat-linux', 's390x', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ppc-redhat-linux', 'ppc', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'aarch64-redhat-linux', 'aarch64', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv7l-redhat-linux', 'armv7l', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv5tejl-redhat-linux', 'armv5tejl', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv6l-redhat-linux', 'armv6l', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv6hl-redhat-linux', 'armv6hl', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'powerpc-debian-linux', 'powerpc Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ppc64-redhat-linux', 'ppc64', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ppc64le-redhat-linux', 'ppc64le', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'pSeries-redhat-linux', 'pSeries', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'iSeries-redhat-linux', 'iSeries', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'x86_64-redhat-linux', 'x86_64', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ppc64iseries-redhat-linux', 'ppc64iseries', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ppc64pseries-redhat-linux', 'ppc64pseries', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'ia32e-redhat-linux', 'EM64T', lookup_arch_type('rpm'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'amd64-redhat-linux', 'AMD64', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'amd64-debian-linux', 'AMD64 Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'arm-debian-linux', 'arm Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv6l-debian-linux', 'arm Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'mips-debian-linux', 'mips Debian', lookup_arch_type('deb'));

insert into rhnServerArch (id, label, name, arch_type_id) values
(sequence_nextval('rhn_server_arch_id_seq'), 'armv7l-debian-linux', 'arm Debian', lookup_arch_type('deb'));

commit;

