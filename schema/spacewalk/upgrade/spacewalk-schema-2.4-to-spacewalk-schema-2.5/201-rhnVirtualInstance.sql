delete from rhnVirtualInstance where virtual_system_id is NULL and host_system_id is not NULL and uuid in (select uuid from rhnVirtualInstance group by uuid having count(uuid) > 1);
delete from rhnVirtualInstance where virtual_system_id is NULL and host_system_id is NULL and uuid is not NULL;
