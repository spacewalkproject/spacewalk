ALTER TABLE rhnKickstartableTree DROP CONSTRAINT rhn_kstree_cid_fk;
ALTER TABLE rhnKickstartableTree ADD CONSTRAINT rhn_kstree_cid_fk FOREIGN KEY (channel_id) REFERENCES rhnChannel (id) ON DELETE CASCADE;
