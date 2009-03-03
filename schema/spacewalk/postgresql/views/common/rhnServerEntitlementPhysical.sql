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
-- $Id: rhnServerEntitlementView.sql 57324 2005-06-01 15:23:37Z jslagle $
--

create or replace view
rhnServerEntitlementPhysical
(
   server_id,
   server_group_id,
   server_group_type_id,
   label,
   permanent,
   is_base,
   modified
)
as
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
        );

