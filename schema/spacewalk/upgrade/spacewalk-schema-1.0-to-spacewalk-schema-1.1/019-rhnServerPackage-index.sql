DELETE FROM rhnServerPackage A
WHERE rowid NOT IN (SELECT min(rowid) min_rowid
                      FROM rhnServerPackage
                     GROUP BY server_id, name_id, evr_id, package_arch_id);

DROP INDEX rhn_sp_snep_idx;
CREATE UNIQUE INDEX rhn_sp_snep_uq
    ON rhnServerPackage (server_id, name_id, evr_id, package_arch_id)
    TABLESPACE [[128m_tbs]]
    NOLOGGING;
