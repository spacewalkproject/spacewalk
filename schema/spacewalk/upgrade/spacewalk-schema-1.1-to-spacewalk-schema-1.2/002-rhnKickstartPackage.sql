ALTER TABLE rhnKickstartPackage
    ADD CONSTRAINT rhn_kspackage_name_uq UNIQUE (kickstart_id, package_name_id)
    USING INDEX TABLESPACE [[4m_tbs]];
