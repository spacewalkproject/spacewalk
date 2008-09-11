--
-- $Id$
--

-- the next two views are basically the same.  the first, though, has an outer join to
-- the errata stuff, in case there are packages the server needs that haven't been
-- errata'd (ie, the fringe case)

CREATE OR REPLACE PROCEDURE
queue_server(server_id_in IN NUMBER, immediate_in IN NUMBER := 1)
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
SHOW ERRORS

-- $Log$
-- Revision 1.8  2004/11/09 18:16:21  pjones
-- bugzilla: none -- make this faster by using the table the second time.
--
-- Revision 1.7  2004/07/13 21:29:35  pjones
-- bugzilla: 125938 -- make queue_server handle new EP table, too
--
-- Revision 1.6  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
