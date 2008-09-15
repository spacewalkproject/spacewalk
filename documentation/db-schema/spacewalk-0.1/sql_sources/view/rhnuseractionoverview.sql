-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNUSERACTIONOVERVIEW" ("ORG_ID", "USER_ID", "ID", "TYPE_NAME", "SCHEDULER", "EARLIEST_ACTION", "ACTION_NAME", "ACTION_STATUS_ID", "ACTION_STATUS", "TALLY", "ARCHIVED") AS 
  select	ao.org_id                                       org_id,
	usp.user_id                                     user_id,
    	ao.action_id                                    id,
	ao.type_name                                    type_name,
        ao.scheduler                                    scheduler,
	ao.earliest_action                              earliest_action,
	decode(ao.name, null, ao.type_name, ao.name)	action_name,
	sa.status					action_status_id,
	astat.name                                      action_status,
	count(sa.action_id)				tally,
	ao.archived                                     archived
from	rhnActionStatus            astat,
    	rhnUserServerPerms         usp,
	rhnServerAction            sa,
	rhnActionOverview	   ao
where	ao.action_id = sa.action_id
  and   sa.server_id = usp.server_id
  and   sa.status = astat.id
group by ao.org_id,
	 usp.user_id,
	 ao.action_id,
	 ao.type_name,
	 ao.scheduler,
	 ao.earliest_action,
	 decode(ao.name, null, ao.type_name, ao.name),
	 sa.status,
	 astat.name,
	 ao.archived
order by earliest_action
 
/
