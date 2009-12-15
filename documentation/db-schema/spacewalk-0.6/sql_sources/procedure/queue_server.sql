-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM1"."QUEUE_SERVER" (server_id_in IN NUMBER, immediate_in IN NUMBER := 1)
IS
    org_id_tmp NUMBER;
BEGIN
    IF immediate_in > 0
    THEN
        DELETE FROM rhnServerNeededCache WHERE server_id = server_id_in;
        INSERT INTO rhnServerNeededCache
       	    (SELECT server_id, errata_id, package_id
	       FROM rhnServerNeededView
              WHERE server_id = server_id_in);

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
