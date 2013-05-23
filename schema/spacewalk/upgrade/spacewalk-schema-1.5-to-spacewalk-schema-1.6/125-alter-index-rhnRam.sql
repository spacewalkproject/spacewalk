delete from rhnram X
	where server_id in (select server_id from rhnram group by server_id having count(server_id)>1)
	 and id<(select max(id) from rhnram Y where X.server_id=Y.server_id group by server_id having count(server_id)>1);

set serverout on;

declare
	non_existent_index exception;
	pragma exception_init(non_existent_index, -01418);
begin
	execute immediate 'drop index rhn_ram_sid_idx';
	dbms_output.put_line('Index rhn_ram_sid_idx successfully dropped.');
exception
	when non_existent_index then
		null;
end;
/

CREATE UNIQUE INDEX rhn_ram_sid_uq
    ON rhnRam (server_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;
