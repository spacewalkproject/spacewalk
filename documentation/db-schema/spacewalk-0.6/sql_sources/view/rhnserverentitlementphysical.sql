-- created by Oraschemadoc Mon Aug 31 10:54:32 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNSERVERENTITLEMENTPHYSICAL" ("SERVER_ID", "SERVER_GROUP_ID", "SERVER_GROUP_TYPE_ID", "LABEL", "PERMANENT", "IS_BASE", "MODIFIED") AS 
  select
   distinct
   sgm.server_id,
   sg.id,
   sgt.id,
   sgt.label,
   sgt.permanent,
   sgt.is_base,
   sgm.modified
from
   rhnServerGroupType sgt,
   rhnServerGroup sg,
   rhnServerGroupMembers sgm
where
   sg.id = sgm.server_group_id
   and sg.group_type = sgt.id
   and not exists (
        select 1
        from
            rhnServerGroup sg2,
            rhnServerGroupMembers sgm2,
            rhnVirtualInstance vi
        where
            vi.virtual_system_id = sgm.server_id
            and vi.host_system_id = sgm2.server_id
            and sgm2.server_group_id = sg2.id
            and sg2.group_type = sg.group_type
            and exists (
                select 1
                from
                    rhnServerGroupType sgt3,
                    rhnServerGroup sg3,
                    rhnServerGroupMembers sgm3
                where
                    sgm3.server_id = sgm2.server_id
                    and sgm3.server_group_id = sg3.id
                    and sg3.group_type = sgt3.id
                    and sgt3.label in ('virtualization_host',
                                       'virtualization_host_platform')
                )
        )
 
/
