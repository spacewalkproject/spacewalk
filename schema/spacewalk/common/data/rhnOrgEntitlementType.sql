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
-- data for rhnOrgEntitlementType

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'sw_mgr_enterprise','Software Manager Enterprise'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_monitor','Spacewalk Monitoring'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_provisioning','Spacewalk Provisioning'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_nonlinux','Spacewalk Non-Linux'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_virtualization', 'Spacewalk Virtualization'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_virtualization_platform', 'Spacewalk Virtualization Platform'
        );


commit;

--
-- Revision 1.4  2004/02/19 20:17:50  pjones
-- bugzilla: 115896 -- add sgt and oet data for nonlinux, add
-- [un]set_customer_nonlinux
--
-- Revision 1.3  2003/09/19 22:35:07  pjones
-- bugzilla: none
--
-- provisioning and config management entitlement support
--
-- Revision 1.2  2002/07/29 21:03:38  rnorwood
-- Cleanup for messages on front page
--
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
