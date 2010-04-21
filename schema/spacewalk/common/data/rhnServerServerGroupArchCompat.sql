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

-- insert 
-- into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
-- values (lookup_server_arch(''), lookup_sg_type(''));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i486-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i586-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i686-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('athlon-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alphaev6-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparcv9-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc64-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390x-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('pSeries-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('iSeries-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('x86_64-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia32e-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('amd64-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64iseries-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64pseries-redhat-linux'), 
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('arm-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('mips-debian-linux'),
            lookup_sg_type('sw_mgr_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i486-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i586-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i686-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('athlon-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alphaev6-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparcv9-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc64-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390x-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('pSeries-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('iSeries-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('x86_64-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia32e-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('amd64-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64iseries-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64pseries-redhat-linux'), 
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('arm-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('mips-debian-linux'),
            lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('sparc-sun4m-solaris'), 
           lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('sparc-sun4u-solaris'), 
           lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('sparc-sun4v-solaris'), 
           lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('i386-i86pc-solaris'), 
           lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i486-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i586-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i686-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('athlon-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-debian-linux'),
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alphaev6-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc-debian-linux'),
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparcv9-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('sparc64-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390x-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('pSeries-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('iSeries-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('x86_64-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('ia32e-redhat-linux'), 
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('amd64-redhat-linux'), 
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('amd64-debian-linux'),
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64iseries-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64pseries-redhat-linux'), 
            lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('arm-debian-linux'),
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('mips-debian-linux'),
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('sparc-sun4m-solaris'), 
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('sparc-sun4u-solaris'), 
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('sparc-sun4v-solaris'), 
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('i386-i86pc-solaris'), 
           lookup_sg_type('provisioning_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i486-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i586-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('i686-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('athlon-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alpha-debian-linux'),
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('alphaev6-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('s390x-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('pSeries-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('iSeries-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('x86_64-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('ia32e-redhat-linux'), 
           lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('amd64-redhat-linux'), 
           lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('amd64-debian-linux'),
           lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64iseries-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
	values (lookup_server_arch('ppc64pseries-redhat-linux'), 
            lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('arm-debian-linux'),
           lookup_sg_type('monitoring_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
   values (lookup_server_arch('mips-debian-linux'),
           lookup_sg_type('monitoring_entitled'));

-- virtualization_host* compatibilities --

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i386-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i486-redhat-linux'), 
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i586-redhat-linux'), 
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i686-redhat-linux'), 
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('athlon-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('amd64-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ia64-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ia32e-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('s390-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('s390-debian-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('s390x-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ppc-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('powerpc-debian-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ppc64-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('x86_64-redhat-linux'),
            lookup_sg_type('virtualization_host'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i386-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i386-debian-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i486-redhat-linux'), 
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i586-redhat-linux'), 
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('i686-redhat-linux'), 
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('athlon-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('amd64-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('amd64-debian-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ia64-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ia64-debian-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('ia32e-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type)
    values (lookup_server_arch('x86_64-redhat-linux'),
            lookup_sg_type('virtualization_host_platform'));

commit;

--
--
-- Revision 1.3  2005/02/15 20:35:05  jslagle
-- bz #140447
-- Dropped column schedule_zone_id.
--
-- Revision 1.2  2004/05/11 18:29:40  pjones
-- bugzilla: none -- make EM64T and AMD64 registerable as such, and fix their
-- names while I'm at it.
--
-- Revision 1.1  2004/02/19 22:19:29  pjones
-- bugzilla: 115896 -- don't let servers subscribe to services for which
-- their server arch is not compatible
--
