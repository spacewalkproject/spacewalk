ALTER TABLE rhnReleaseChannelMap DROP CONSTRAINT rhn_rcm_pva_def_uniq;
ALTER TABLE rhnReleaseChannelMap DROP COLUMN is_default;
ALTER TABLE rhnReleaseChannelMap 
ADD CONSTRAINT rhn_rcm_pvar_uniq
unique (product, version, channel_arch_id, release);
