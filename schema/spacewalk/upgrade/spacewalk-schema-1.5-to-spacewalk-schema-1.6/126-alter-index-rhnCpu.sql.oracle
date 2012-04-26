delete from rhncpu X
	where server_id in (select server_id from rhncpu group by server_id having count(server_id)>1)
	 and id<(select max(id) from rhncpu Y where X.server_id=Y.server_id group by server_id having count(server_id)>1);

DROP INDEX rhn_cpu_server_id_idx;

CREATE UNIQUE INDEX rhn_cpu_server_id_uq
    ON rhnCpu (server_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;
