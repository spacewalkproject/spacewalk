-- created by Oraschemadoc Fri Jan 22 13:40:43 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM_H1"."RHNPAIDORGS" ("ORG_ID") AS 
  select	org_id
from	rhnServerGroup
where	group_type = lookup_sg_type('enterprise_entitled')
	and coalesce(max_members,1) > 0
union all
select	sg.org_id
from	rhnServerGroup sg
where	sg.group_type = lookup_sg_type('sw_mgr_entitled')
	and coalesce(sg.max_members,1) > 0
    and not exists (
        select 1
        from
            rhnDemoOrgs d
        where
            d.org_id = sg.org_id
            and sg.max_members = 1
    )
union all
select	sg.org_id
from	rhnServerGroup sg
where	group_type = lookup_sg_type('provisioning_entitled')
	and coalesce(sg.max_members,2) > 1
 
/
