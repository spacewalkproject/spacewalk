-- oracle equivalent source sha1 fd8c26dc60bc3a72e5b84629b4e37e74124e3037

-- rhnServerGroup and dependencies

SELECT logging.clear_log_id();

DELETE FROM rhnOrgExtGroupMapping
  WHERE server_group_id in (
    SELECT id
      FROM rhnServerGroup
      WHERE group_type = (
        SELECT id
          FROM rhnServerGroupType
          WHERE label = 'nonlinux_entitled'
      )
  );

DELETE FROM rhnRegTokenGroups
  WHERE server_group_id in (
    SELECT id
      FROM rhnServerGroup
      WHERE group_type = (
        SELECT id
          FROM rhnServerGroupType
          WHERE label = 'nonlinux_entitled'
      )
  );

DELETE FROM rhnServerGroupMembers
  WHERE server_group_id in (
    SELECT id
      FROM rhnServerGroup
      WHERE group_type = (
        SELECT id
          FROM rhnServerGroupType
          WHERE label = 'nonlinux_entitled'
      )
  );

DELETE FROM rhnSnapshotServerGroup
  WHERE server_group_id in (
    SELECT id
      FROM rhnServerGroup
      WHERE group_type = (
        SELECT id
          FROM rhnServerGroupType
          WHERE label = 'nonlinux_entitled'
      )
  );

DELETE FROM rhnUserDefaultSystemGroups
  WHERE system_group_id in (
    SELECT id
      FROM rhnServerGroup
      WHERE group_type = (
        SELECT id
          FROM rhnServerGroupType
          WHERE label = 'nonlinux_entitled'
      )
  );

DELETE FROM rhnUserServerGroupPerms
  WHERE server_group_id in (
    SELECT id
      FROM rhnServerGroup
      WHERE group_type = (
        SELECT id
          FROM rhnServerGroupType
          WHERE label = 'nonlinux_entitled'
      )
  );

DELETE FROM rhnServerGroup
  WHERE group_type = (
    SELECT id
      FROM rhnServerGroupType
      WHERE label = 'nonlinux_entitled'
  );

-- rhnServerGroupType and dependencies

DELETE FROM rhnRegTokenEntitlement
  WHERE server_group_type_id = (
    SELECT id
      FROM rhnServerGroupType
      WHERE label = 'nonlinux_entitled'
  );

DELETE FROM rhnServerGroupTypeFeature
  WHERE server_group_type_id = (
    SELECT id
      FROM rhnServerGroupType
      WHERE label = 'nonlinux_entitled'
  );

DELETE FROM rhnServerServerGroupArchCompat
  WHERE server_group_type = (
    SELECT id
      FROM rhnServerGroupType
      WHERE label = 'nonlinux_entitled'
  );

DELETE FROM rhnSGTypeBaseAddonCompat
  WHERE base_id = (
    SELECT id
      FROM rhnServerGroupType
      WHERE label = 'nonlinux_entitled'
  );

DELETE FROM rhnServerGroupType
  WHERE label = 'nonlinux_entitled';

-- rhnOrgEntitlementType

DELETE FROM rhnOrgEntitlements
  WHERE entitlement_id = (
    SELECT id
      FROM rhnOrgEntitlementType
      WHERE label = 'rhn_nonlinux'
  );

DELETE FROM rhnOrgEntitlementType
  WHERE label = 'rhn_nonlinux';

-- rhnFeature

DELETE FROM rhnFeature
  WHERE label = 'ftr_nonlinux_support';
