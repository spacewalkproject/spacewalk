-- oracle equivalent source sha1 85b76b18e46469c02356970e4ea513f91658d73a
-- function index for rhnServerNetInterface

CREATE UNIQUE INDEX rhn_srv_net_iface_prim_iface
  ON rhnServerNetInterface
  (server_id) where is_primary is not null;
