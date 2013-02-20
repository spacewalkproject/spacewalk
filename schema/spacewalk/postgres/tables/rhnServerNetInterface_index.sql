-- function index for rhnServerNetInterface

CREATE UNIQUE INDEX rhn_srv_net_iface_prim_iface
  ON rhnServerNetInterface
  (server_id) where is_primary is not null;
