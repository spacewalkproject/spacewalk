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

insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'i386', 'i386');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'i486', 'i486');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'i586', 'i586');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'i686', 'i686');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'athlon', 'athlon');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'alpha', 'alpha');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'alphaev6', 'alphaev6');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'ia64', 'ia64');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'sparc', 'sparc');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'sparcv9', 'sparcv9');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'sparc64', 'sparc64');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 's390', 's390');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 's390x', 's390x');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'ppc', 'ppc');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'ppc64', 'ppc64');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'pSeries', 'pSeries');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'iSeries', 'iSeries');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'x86_64', 'x86_64');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'sun4u', 'sun4u');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'sun4v', 'sun4v');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'sun4m', 'sun4m');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'ia32e', 'EM64T');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'amd64', 'AMD64');
insert into rhnCpuArch (id, label, name) values
(rhn_cpu_arch_id_seq.nextval, 'i86pc', 'i86pc');
commit;

--
-- Revision 1.6  2004/05/11 18:29:40  pjones
-- bugzilla: none -- make EM64T and AMD64 registerable as such, and fix their
-- names while I'm at it.
--
-- Revision 1.5  2004/02/18 23:41:04  pjones
-- bugzilla: 116188 -- ia32e
--
-- Revision 1.4  2004/02/11 20:19:57  misa
-- New architectures for sun
--
-- Revision 1.3  2003/01/29 17:11:36  misa
-- bugzilla: 83022  Adding x86_64 as a supported arch
--
-- Revision 1.2  2002/11/14 18:00:59  pjones
-- commits
--
-- Revision 1.1  2002/11/14 16:35:08  misa
-- Populating the table
--
