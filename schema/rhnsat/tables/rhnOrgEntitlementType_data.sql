--
-- $Id$
--
-- data for rhnOrgEntitlementType

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'sw_mgr_enterprise','Software Manager Enterprise'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_monitor','Red Hat Network Monitoring'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_provisioning','Red Hat Network Provisioning'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_nonlinux','Red Hat Network Non-Linux'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_virtualization', 'Red Hat Network Virtualization'
        );

insert into rhnOrgEntitlementType (id, label, name)
        values (rhn_org_entitlement_type_seq.nextval,
                'rhn_virtualization_platform', 'Red Hat Network Virtualization Platform'
        );


commit;

-- $Log$
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
