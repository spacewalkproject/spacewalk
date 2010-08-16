DELETE FROM rhnServerPackage A
 WHERE EXISTS
   (SELECT 1 FROM (SELECT server_id,
                          name_id,
                          evr_id,
                          package_arch_id,
                          min(rowid) min_rowid
                     FROM rhnServerPackage
                    GROUP BY server_id, name_id, evr_id, package_arch_id
                   HAVING count(*) > 1) N
            WHERE a.server_id = n.server_id
              AND a.name_id = n.name_id
              AND a.evr_id = n.evr_id
              AND a.package_arch_id = n.package_arch_id
              AND a.rowid > n.min_rowid);

DROP INDEX rhn_sp_snep_idx;
CREATE UNIQUE INDEX rhn_sp_snep_uq
    ON rhnServerPackage (server_id, name_id, evr_id, package_arch_id)
    TABLESPACE [[128m_tbs]]
    NOLOGGING;
