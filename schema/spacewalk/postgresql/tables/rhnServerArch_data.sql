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

insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'i386-redhat-linux', 'i386', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'i486-redhat-linux', 'i486', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'i586-redhat-linux', 'i586', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'i686-redhat-linux', 'i686', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'athlon-redhat-linux', 'athlon', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'alpha-redhat-linux', 'alpha', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'alphaev6-redhat-linux', 'alphaev6', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'ia64-redhat-linux', 'ia64', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'sparc-redhat-linux', 'sparc', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'sparcv9-redhat-linux', 'sparcv9', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'sparc64-redhat-linux', 'sparc64', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 's390-redhat-linux', 's390', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 's390x-redhat-linux', 's390x', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'ppc-redhat-linux', 'ppc', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'ppc64-redhat-linux', 'ppc64', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'pSeries-redhat-linux', 'pSeries', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'iSeries-redhat-linux', 'iSeries', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'x86_64-redhat-linux', 'x86_64', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'ppc64iseries-redhat-linux', 'ppc64iseries', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'ppc64pseries-redhat-linux', 'ppc64pseries', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'sparc-sun4m-solaris', 'Sparc Solaris', lookup_arch_type('sysv-solaris'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'sparc-sun4u-solaris', 'Sparc Solaris', lookup_arch_type('sysv-solaris'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'sparc-sun4v-solaris', 'Sparc Solaris', lookup_arch_type('sysv-solaris'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'ia32e-redhat-linux', 'EM64T', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'amd64-redhat-linux', 'AMD64', lookup_arch_type('rpm'));
insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'i386-i86pc-solaris', 'i386 Solaris', lookup_arch_type('sysv-solaris'));

