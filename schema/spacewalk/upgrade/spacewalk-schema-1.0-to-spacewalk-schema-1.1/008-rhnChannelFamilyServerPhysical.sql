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
-- $Id: rhnChannelFamilyServers.sql 43207 2003-04-11 20:46:21Z cturner $
--

create or replace view rhnChannelFamilyServerPhysical as
	select	rs.org_id			as customer_id,
		rcfm.channel_family_id		as channel_family_id,
		rsc.server_id			as server_id,
		rsc.created			as created,
		rsc.modified			as modified
	from	rhnChannelFamilyMembers		rcfm,
		rhnServerChannel		rsc,
		rhnServer			rs
	where
		rcfm.channel_id = rsc.channel_id
		and rsc.server_id = rs.id
         and rsc.is_fve = 'N'
        and not exists (
                select 1
                from 
                    rhnChannelFamilyVirtSubLevel cfvsl, 
                    rhnSGTypeVirtSubLevel sgtvsl,
                    rhnServerEntitlementView sev,
                    rhnVirtualInstance vi
                where 
                    -- system is a virtual instance
                    vi.virtual_system_id = rs.id
                    and vi.host_system_id = sev.server_id
                    -- system's host has a virt ent
                    and sev.label in ('virtualization_host',
                                      'virtualization_host_platform')
                    and sev.server_group_type_id = sgtvsl.server_group_type_id
                    -- the host's virt ent grants a cf virt sub level
                    and sgtvsl.virt_sub_level_id = cfvsl.virt_sub_level_id
                    -- the cf is in that virt sub level
                    and cfvsl.channel_family_id = rcfm.channel_family_id
                );

