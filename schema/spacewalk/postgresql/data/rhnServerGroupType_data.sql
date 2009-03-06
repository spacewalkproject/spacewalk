--
-- Copyright (c) 2009 Red Hat, Inc.
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
-- data for rhnServerGroupType

-- sw_mgr_entitled type ------------------------------------------------------

insert into rhnServerGroupType (id, label, name, permanent, is_base)
        values (sequence_nextval('rhn_servergroup_type_seq'),
                'sw_mgr_entitled', 'Spacewalk Update Entitled Servers',
                'N', 'Y'
        );

-- enterprise_entitled type --------------------------------------------------

insert into rhnServerGroupType (id, label, name, permanent, is_base)
        values (sequence_nextval('rhn_servergroup_type_seq'),
                'enterprise_entitled', 'Spacewalk Management Entitled Servers',
                'N', 'Y'
        );

-- provisioning_entitled type ------------------------------------------------

insert into rhnServerGroupType (id, label, name, permanent, is_base)
        values (sequence_nextval('rhn_servergroup_type_seq'),
                'provisioning_entitled', 'Spacewalk Provisioning Entitled Servers',
                'N', 'N'
        );

-- monitoring_entitled type --------------------------------------------------

insert into rhnServerGroupType (id, label, name, permanent, is_base)
	values (sequence_nextval('rhn_servergroup_type_seq'),
		'monitoring_entitled', 'Spacewalk Monitoring Entitled Servers',
        'N', 'N'
	);

-- nonlinux_entitled type ----------------------------------------------------

insert into rhnServerGroupType ( id, label, name, permanent, is_base)
   values (sequence_nextval('rhn_servergroup_type_seq'),
      'nonlinux_entitled', 'Non-Linux Entitled Servers',
      'N', 'Y'
   );

-- virtualization_* types ----------------------------------------------------

insert into rhnServerGroupType ( id, label, name, permanent, is_base)
   values (sequence_nextval('rhn_servergroup_type_seq'),
      'virtualization_host', 'Virtualization Host Entitled Servers',
      'N', 'N'
   );

insert into rhnServerGroupType ( id, label, name, permanent, is_base)
   values (sequence_nextval('rhn_servergroup_type_seq'),
      'virtualization_host_platform',
      'Virtualization Host Platform Entitled Servers',
      'N', 'N'
   );


