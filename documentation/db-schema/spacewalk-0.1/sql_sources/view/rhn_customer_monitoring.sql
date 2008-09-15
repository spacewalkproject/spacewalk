-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHN_CUSTOMER_MONITORING" ("RECID", "DESCRIPTION", "SCHEDULE_ID", "DEF_ACK_WAIT", "DEF_STRATEGY", "PREFERRED_TIME_ZONE", "AUTO_UPDATE") AS 
  select	org.id			recid,
	org.name		description,
	1			schedule_id,	--24 x 7
	0			def_ack_wait,
	1			def_strategy,	--Broadcast, No Ack
	'GMT'			preferred_time_zone,
	0			auto_update	--Windows only
from
	web_customer org
where	1=1
 
/
