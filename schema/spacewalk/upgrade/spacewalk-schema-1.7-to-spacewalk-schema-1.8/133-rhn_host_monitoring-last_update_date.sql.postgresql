-- oracle equivalent source sha1 b5af1ebd3963dd38161b7421ceee8708a8db9243

drop view rhn_host_monitoring;
create view rhn_host_monitoring
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
        rhn_server.get_ip_address(s.id) as ip,
        s.name          as name,
        s.description   as description,
        s.org_id        as customer_id,
        4               as os_id,
        to_number(null,null) as asset_id,
        cast(null as char)   as last_update_user,
        cast(null as TIMESTAMPTZ)   as last_update_date
from    rhnServer       s
;

