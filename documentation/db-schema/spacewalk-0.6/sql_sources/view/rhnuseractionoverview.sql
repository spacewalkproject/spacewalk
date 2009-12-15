-- created by Oraschemadoc Mon Aug 31 10:54:34 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNUSERACTIONOVERVIEW" ("ORG_ID", "USER_ID", "ID", "TYPE_NAME", "SCHEDULER", "EARLIEST_ACTION", "ACTION_NAME", "ACTION_STATUS_ID", "ACTION_STATUS", "TALLY", "ARCHIVED") AS 
  select	ao.org_id                                       as org_id,
	usp.user_id                                     as user_id,
    	ao.action_id                                    as id,
	ao.type_name                                    as type_name,
        ao.scheduler                                    as scheduler,
	ao.earliest_action                              as earliest_action,
	coalesce( ao.name, ao.type_name )		as action_name,
	sa.status					as action_status_id,
	astat.name                                      as action_status,
	count(sa.action_id)				as tally,
	ao.archived                                     as archived
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
	 coalesce( ao.name, ao.type_name ),
	 sa.status,
	 astat.name,
	 ao.archived
order by earliest_action
 
/
