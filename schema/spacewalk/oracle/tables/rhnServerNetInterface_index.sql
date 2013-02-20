-- functional index for rhnServerNetInterface

CREATE UNIQUE INDEX rhn_srv_net_iface_prim_iface
  ON rhnServerNetInterface
  (CASE WHEN is_primary IS NULL THEN NULL ELSE server_id END);
