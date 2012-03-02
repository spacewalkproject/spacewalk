-- created by Oraschemadoc Fri Mar  2 05:58:00 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNSERVERFVECAPABLE" ("SERVER_ID", "SERVER_ORG_ID", "CHANNEL_FAMILY_ID", "CURRENT_MEMBERS", "MAX_MEMBERS", "CHANNEL_FAMILY_NAME") AS 
  select  S.id as server_id,
        S.org_id as server_org_id,
        cf.id as channel_family_id,
        pcf.FVE_CURRENT_MEMBERS as current_members,
        pcf.FVE_MAX_MEMBERS as max_members,
        cf.name as channel_family_name
from
     RhnVirtualInstance vi
     inner join rhnServer s on vi.virtual_system_id = s.id
     inner join rhnServerChannel sc on sc.server_id = s.id
     inner join rhnChannelFamilyMembers cfm on cfm.channel_id = sc.channel_id
     inner join rhnChannelFamily cf on cf.id = cfm.channel_family_id
     inner join rhnPrivateChannelFamily pcf on pcf.channel_family_id  = cf.id and pcf.org_id = s.org_id
where sc.is_fve = 'N'
     AND (vi.host_system_id is null OR
     not exists (
          select sg.id
            from rhnServerGroupMembers sgm
                 inner join rhnServerGroup sg on sgm.server_group_id = sg.id
                 inner join rhnServerGroupType sgt on sgt.id = sg.group_type
                 inner join rhnServer s2 on s2.id = sgm.server_id
             where
                 s2.id = vi.host_system_id
                 and sgt.label in ('virtualization_host' ,'virtualization_host_platform') )
      )
 
/
