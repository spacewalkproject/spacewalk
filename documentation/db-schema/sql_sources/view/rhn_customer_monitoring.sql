-- created by Oraschemadoc Fri Mar  2 05:58:04 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHN_CUSTOMER_MONITORING" ("RECID", "DESCRIPTION", "SCHEDULE_ID", "DEF_ACK_WAIT", "DEF_STRATEGY", "PREFERRED_TIME_ZONE", "AUTO_UPDATE") AS 
  select	org.id			as recid,
	org.name		as description,
	1			as schedule_id,	--24 x 7
	0			as def_ack_wait,
	1			as def_strategy,	--Broadcast, No Ack
	'GMT' || ''		as preferred_time_zone,
	0			as auto_update	--Windows only
from
	web_customer org

 
/
