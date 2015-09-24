-- oracle equivalent source sha1 89fecdfd2b9366cde29ad7ae70aecaad64b73ea5
-- retrieved from ./1241128047/984a347f2afbd47756e90584364799dd670b62db/schema/spacewalk/oracle/procs/queue_server.sql
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

-- the next two views are basically the same.  the first, though, has an outer join to
-- the errata stuff, in case there are packages the server needs that haven't been
-- errata'd (ie, the fringe case)


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
          SELECT org_id_tmp,
                 'update_server_errata_cache',
                 server_id_in
          WHERE NOT EXISTS
            (SELECT 1 FROM rhnTaskQueue
               WHERE org_id = org_id_tmp
               AND task_name = 'update_server_errata_cache'
               AND task_data = server_id_in
            );
    END IF;
END;
$$ LANGUAGE plpgsql;
