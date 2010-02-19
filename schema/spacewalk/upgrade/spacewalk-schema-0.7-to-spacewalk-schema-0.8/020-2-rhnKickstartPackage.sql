DROP INDEX rhn_kspackage_id_idx;

ALTER TABLE rhnKickstartPackage
    ADD CONSTRAINT rhn_kspackage_pos_uq UNIQUE (kickstart_id, position)
    USING INDEX TABLESPACE [[4m_tbs]];
