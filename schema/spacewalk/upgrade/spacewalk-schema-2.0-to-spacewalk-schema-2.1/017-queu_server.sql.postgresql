-- oracle equivalent source sha1 201391ef62bd6dfd74d50e93a9753e85ffae8871

CREATE OR REPLACE FUNCTION
queue_server(server_id_in IN NUMERIC, immediate_in IN NUMERIC DEFAULT 1)
RETURNS VOID
AS
$$
DECLARE
    org_id_tmp NUMERIC;
BEGIN
    IF immediate_in > 0
    THEN
          PERFORM rhn_server.update_needed_cache(server_id_in);
    ELSE
          SELECT org_id INTO STRICT org_id_tmp
          FROM rhnServer WHERE id = server_id_in;

          INSERT
            INTO rhnTaskQueue
                 (org_id, task_name, task_data)
          VALUES (org_id_tmp,
                  'update_server_errata_cache',
                  server_id_in);
    END IF;
END;
$$ LANGUAGE plpgsql;
