create index rhn_snc_speid_idx
        on rhnServerNeededCache(server_id, package_id, errata_id)
        noparallel
        tablespace [[128m_tbs]]
        nologging;

alter index rhn_snc_pid_idx noparallel;
alter index rhn_snc_sid_idx noparallel;
alter index rhn_snc_eid_idx noparallel;

