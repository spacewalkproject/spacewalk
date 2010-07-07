--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--
-- A view to list systems that fve capable but that are not actually using
--    and fve entitlement
create or replace view 
rhnServerFveCapable (
 server_id,
 server_org_id,
 channel_family_id,
 current_members,
 max_members,
 channel_family_name
)
as
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
     exists (
          select sg.id 
            from rhnServerGroupMembers sgm
                 inner join rhnServerGroup sg on sgm.server_group_id = sg.id
                 inner join rhnServerGroupType sgt on sgt.id = sg.group_type
                 inner join rhnServer s2 on s2.id = sgm.server_id
             where
                 s2.org_id = s.org_id
                 and s2.id = vi.host_system_id
                 and sgt.label not in ('virtualization_host' ,'virtualization_host_platform') )
      );

