create index rhn_snc_speid_idx
        on rhnServerNeededCache(server_id, package_id, errata_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;
