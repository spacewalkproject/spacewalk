-- oracle equivalent source sha1 4e2847469a40fce977edb5b8e183c0a2f78a7db1

ALTER TABLE rhnServerNetInterface ADD COLUMN is_primary VARCHAR(1);

CREATE UNIQUE INDEX rhn_srv_net_iface_prim_iface
  ON rhnServerNetInterface
  (server_id) where is_primary is not null;
