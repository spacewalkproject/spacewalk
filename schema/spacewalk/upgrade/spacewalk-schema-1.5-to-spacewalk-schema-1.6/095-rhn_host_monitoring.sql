drop view rhn_host_monitoring;
create or replace view rhn_host_monitoring
(
	recid,
	ip,
	name,
	description,
	customer_id,
	os_id,
	asset_id,
	last_update_user,
	last_update_date
) as
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
;
