--
-- $Id: rhnChannelFamilyServers.sql 43207 2003-04-11 20:46:21Z cturner $
--

create or replace view rhnChannelFamilyServerPhysical as
	select	rs.org_id			customer_id,
		rcfm.channel_family_id		channel_family_id,
		rsc.server_id			server_id,
		rsc.created			created,
		rsc.modified			modified
	from	rhnChannelFamilyMembers		rcfm,
		rhnChannelFamily		rcf,
		rhnServerChannel		rsc,
		rhnServer			rs
	where
		rcfm.channel_id = rsc.channel_id
		and rcfm.channel_family_id = rcf.id
		and rsc.server_id = rs.id
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
                    and cfvsl.channel_family_id = rcf.id
                );

show errors;                
