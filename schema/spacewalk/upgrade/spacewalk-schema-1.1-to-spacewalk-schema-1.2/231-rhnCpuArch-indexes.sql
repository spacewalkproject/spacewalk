ALTER TABLE rhnCpuArch DROP CONSTRAINT rhn_cpuarch_label_uq;
DROP INDEX rhn_cpuarch_l_id_n_idx;

ALTER TABLE rhnCpuArch
    ADD CONSTRAINT rhn_cpuarch_label_uq UNIQUE (label)
    USING INDEX TABLESPACE [[2m_tbs]];

