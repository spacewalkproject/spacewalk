-- created by Oraschemadoc Fri Jan 22 13:40:48 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHN_CUSTOMER_MONITORING" ("RECID", "DESCRIPTION", "SCHEDULE_ID", "DEF_ACK_WAIT", "DEF_STRATEGY", "PREFERRED_TIME_ZONE", "AUTO_UPDATE") AS
  select	org.id			recid,
	org.name		description,
	1			schedule_id,	--24 x 7
				--references rhn_schedules(recid)
	0			def_ack_wait,
	1			def_strategy,	--Broadcast, No Ack
				--references rhn_strategies(recid)
	'GMT'			preferred_time_zone,
				--references rhn_time_zone_names(java_id)
	0			auto_update	--Windows only
from
	web_customer org
where	1=1
 
/
