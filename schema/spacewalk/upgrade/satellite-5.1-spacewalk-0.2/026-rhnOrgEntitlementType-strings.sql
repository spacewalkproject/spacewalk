
update rhnOrgEntitlementType
set name = 'Spacewalk Monitoring'
where label = 'rhn_monitor';

update rhnOrgEntitlementType
set name = 'Spacewalk Provisioning'
where label = 'rhn_provisioning';

update rhnOrgEntitlementType
set name = 'Spacewalk Non-Linux'
where label = 'rhn_nonlinux';

update rhnOrgEntitlementType
set name = 'Spacewalk Virtualization'
where label = 'rhn_virtualization';

update rhnOrgEntitlementType
set name = 'Spacewalk Virtualization Platform'
where label = 'rhn_virtualization_platform';

