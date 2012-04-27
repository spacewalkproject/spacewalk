ALTER TABLE rhnChannelArch
    ADD CONSTRAINT rhn_carch_name_uq UNIQUE (name)
    USING INDEX TABLESPACE [[2m_tbs]];
