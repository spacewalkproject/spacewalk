-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNACTIONOVERVIEW" ("ORG_ID", "ACTION_ID", "TYPE_ID", "TYPE_NAME", "NAME", "SCHEDULER", "SCHEDULER_LOGIN", "EARLIEST_ACTION", "TOTAL_COUNT", "SUCCESSFUL_COUNT", "FAILED_COUNT", "IN_PROGRESS_COUNT", "ARCHIVED") AS 
  SELECT    A.org_id,
	  A.id,
	  AT.id,
	  AT.name,
	  A.name,
	  A.scheduler,
	  U.login,
	  A.earliest_action,
	  (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id),
	  (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status = 2), -- XXX: don''t hard code status here :)
	  (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status = 3),
	  (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status NOT IN (2, 3)),
	  A.archived
FROM
	  web_contact U,
	  rhnActionType AT,
	  rhnAction A
WHERE	  A.scheduler = U.id(+)
AND	  A.action_type = AT.id
ORDER BY  A.earliest_action
 
/
