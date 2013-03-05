delete from rhnram X
	where server_id in (select server_id from rhnram group by server_id having count(server_id)>1)
	 and id<(select max(id) from rhnram Y where X.server_id=Y.server_id group by server_id having count(server_id)>1);

DROP INDEX rhn_ram_sid_idx;

CREATE UNIQUE INDEX rhn_ram_sid_uq
    ON rhnRam (server_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;
