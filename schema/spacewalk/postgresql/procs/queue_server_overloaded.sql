-- Creating an overloaded function for queue_server so that it can be called from app with one parameter.

CREATE OR REPLACE FUNCTION
queue_server(server_id_in IN NUMERIC)
RETURNS VOID
AS
$$
DECLARE
    org_id_tmp NUMERIC;
    immediate_in_tmp NUMERIC;
BEGIN
	immediate_in_tmp := 1;
    IF immediate_in_tmp > 0
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
END;
$$ LANGUAGE plpgsql;
