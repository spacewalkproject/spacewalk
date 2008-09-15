-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "RHNSAT"."QUEUE_SERVER" (server_id_in IN NUMBER, immediate_in IN NUMBER := 1)
IS
    org_id_tmp NUMBER;
BEGIN
    IF immediate_in > 0
    THEN
        DELETE FROM rhnServerNeededPackageCache WHERE server_id = server_id_in;
        INSERT INTO rhnServerNeededPackageCache
       	    (SELECT org_id, server_id, errata_id, package_id
	       FROM rhnServerNeededPackageView
              WHERE server_id = server_id_in);
	DELETE FROM rhnServerNeededErrataCache snec WHERE server_id = server_id_in;
	insert into rhnServerNeededErrataCache
	    (select distinct org_id, server_id, errata_id
	       from rhnServerNeededPackageCache
	      where server_id = server_id_in
	        and errata_id is not null);
    ELSE
          SELECT org_id INTO org_id_tmp FROM rhnServer WHERE id = server_id_in;
	  INSERT
            INTO rhnTaskQueue
                 (org_id, task_name, task_data)
          VALUES (org_id_tmp,
                  'update_server_errata_cache',
                  server_id_in);
    END IF;
END queue_server;
 
/
