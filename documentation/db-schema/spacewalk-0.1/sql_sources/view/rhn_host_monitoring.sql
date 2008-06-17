-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHN_HOST_MONITORING" ("RECID", "IP", "NAME", "DESCRIPTION", "CUSTOMER_ID", "OS_ID", "ASSET_ID", "LAST_UPDATE_USER", "LAST_UPDATE_DATE") AS 
  select  s.id            recid,
	rhn_server.get_ip_address(s.id)	ip,
        s.name          name,
        s.description   description,
        s.org_id        customer_id,
        '4'             os_id,
        null            asset_id,
        null            last_update_user,
        null            last_update_date
from	rhnServer	s
 
/
