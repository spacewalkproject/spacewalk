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
-- data for rhnServerGroupType

-- sw_mgr_entitled type ------------------------------------------------------

insert into rhnServerGroupType (id, label, name, permanent, is_base)
        values (rhn_servergroup_type_seq.nextval,
                'sw_mgr_entitled', 'Spacewalk Update Entitled Servers', 
                'N', 'Y'
        );

-- enterprise_entitled type --------------------------------------------------

insert into rhnServerGroupType (id, label, name, permanent, is_base)
        values (rhn_servergroup_type_seq.nextval,
                'enterprise_entitled', 'Spacewalk Management Entitled Servers', 
                'N', 'Y'
        );

-- provisioning_entitled type ------------------------------------------------

insert into rhnServerGroupType (id, label, name, permanent, is_base)
        values (rhn_servergroup_type_seq.nextval,
                'provisioning_entitled', 'Spacewalk Provisioning Entitled Servers', 
                'N', 'N'
        );

-- monitoring_entitled type --------------------------------------------------

insert into rhnServerGroupType (id, label, name, permanent, is_base)
	values (rhn_servergroup_type_seq.nextval,
		'monitoring_entitled', 'Spacewalk Monitoring Entitled Servers', 
        'N', 'N'
	);

-- nonlinux_entitled type ----------------------------------------------------

insert into rhnServerGroupType ( id, label, name, permanent, is_base)
   values ( rhn_servergroup_type_seq.nextval,
      'nonlinux_entitled', 'Non-Linux Entitled Servers',
      'N', 'Y'
   );

-- virtualization_* types ----------------------------------------------------

insert into rhnServerGroupType ( id, label, name, permanent, is_base)
   values ( rhn_servergroup_type_seq.nextval,
      'virtualization_host', 'Virtualization Host Entitled Servers',
      'N', 'N'
   );      

insert into rhnServerGroupType ( id, label, name, permanent, is_base)
   values ( rhn_servergroup_type_seq.nextval,
      'virtualization_host_platform', 
      'Virtualization Host Platform Entitled Servers',
      'N', 'N'
   );      


commit;

--
-- Revision 1.7  2004/05/25 21:41:48  pjones
-- bugzilla: 123639 -- monitoring SG type.
--
-- Revision 1.6  2004/02/19 20:17:50  pjones
-- bugzilla: 115896 -- add sgt and oet data for nonlinux, add
-- [un]set_customer_nonlinux
--
-- Revision 1.5  2003/09/24 15:40:37  pjones
-- bugzilla: 103233
--
-- changes for new names
--
-- Revision 1.4  2003/09/19 22:35:07  pjones
-- bugzilla: none
--
-- provisioning and config management entitlement support
--
-- Revision 1.3  2002/05/31 15:44:08  cturner
-- fix from last night
--
-- Revision 1.2  2002/05/23 20:20:51  cturner
-- remove old vestigal silly server group type
--
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
