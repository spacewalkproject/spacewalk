-- created by Oraschemadoc Fri Mar  2 05:58:04 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHN_HOST_MONITORING" ("RECID", "IP", "NAME", "DESCRIPTION", "CUSTOMER_ID", "OS_ID", "ASSET_ID", "LAST_UPDATE_USER", "LAST_UPDATE_DATE") AS 
  select  s.id            as recid,
	rhn_server.get_ip_address(s.id)	as ip,
        s.name          as name,
        s.description   as description,
        s.org_id        as customer_id,
        4               as os_id,
        to_number(null,null) as asset_id,
        cast(null as char)   as last_update_user,
        cast(null as date)   as last_update_date
from	rhnServer	s

 
/
