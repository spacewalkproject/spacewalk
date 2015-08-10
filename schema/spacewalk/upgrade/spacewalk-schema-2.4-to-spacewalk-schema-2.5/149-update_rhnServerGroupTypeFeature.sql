UPDATE rhnServerGroupTypeFeature
  SET server_group_type_id = (
    SELECT id
      FROM rhnServerGroupType
      WHERE label = 'enterprise_entitled'
  )
  WHERE server_group_type_id = (
    SELECT id
      FROM rhnServerGroupType
      WHERE label = 'provisioning_entitled'
  );