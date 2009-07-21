-- This change is not needed in VADER, since we drop the constraint later
-- in the schema upgrade course. Additionaly, depending on the status of
-- currently synced content, this constraint may cause ORA-02299: cannot
-- validate RHN_RCM_PVA_DEF_UNIQ - duplicate keys found

-- ALTER TABLE rhnReleaseChannelMap
-- ADD CONSTRAINT rhn_rcm_pva_def_uniq
-- UNIQUE (product, version, channel_arch_id, is_default);
