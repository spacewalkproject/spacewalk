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

insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'i386', 'i386');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'i486', 'i486');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'i586', 'i586');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'i686', 'i686');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'athlon', 'athlon');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'alpha', 'alpha');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'alphaev6', 'alphaev6');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'ia64', 'ia64');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'sparc', 'sparc');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'sparcv9', 'sparcv9');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'sparc64', 'sparc64');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 's390', 's390');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 's390x', 's390x');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'ppc', 'ppc');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'ppc64', 'ppc64');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'pSeries', 'pSeries');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'iSeries', 'iSeries');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'x86_64', 'x86_64');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'sun4u', 'sun4u');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'sun4v', 'sun4v');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'sun4m', 'sun4m');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'ia32e', 'EM64T');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'amd64', 'AMD64');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'i86pc', 'i86pc');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'aarch64', 'AArch64');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'armv7l', 'ARMv7l');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'armv5tejl', 'ARMv5tejl');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'armv6l', 'ARMv6l');
insert into rhnCpuArch (id, label, name) values
(sequence_nextval('rhn_cpu_arch_id_seq'), 'armv6hl', 'ARMv6hl');
commit;

