DELETE FROM rhnOrgEntitlements
WHERE entitlement_id IN
    (SELECT id FROM rhnOrgEntitlementType WHERE label = 'rhn_monitor');
