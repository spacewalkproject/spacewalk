delete from rhnServerDMI X
       where server_id in (select server_id from rhnServerDMI group by server_id having count(server_id)>1)
        and id<(select max(id) from rhnServerDMI Y where X.server_id=Y.server_id group by server_id having count(server_id)>1);

DROP INDEX rhn_server_dmi_sid_idx;

CREATE UNIQUE INDEX rhn_server_dmi_sid_uq
    ON rhnServerDMI (server_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;
