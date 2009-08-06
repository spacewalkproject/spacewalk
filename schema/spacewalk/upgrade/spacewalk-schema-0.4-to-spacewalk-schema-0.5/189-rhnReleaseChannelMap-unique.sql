ALTER TABLE rhnReleaseChannelMap
ADD CONSTRAINT rhn_rcm_pva_def_uniq
UNIQUE (product, version, channel_arch_id, is_default);
