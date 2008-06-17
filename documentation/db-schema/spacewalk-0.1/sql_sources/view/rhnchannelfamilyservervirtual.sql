-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNCHANNELFAMILYSERVERVIRTUAL" ("CUSTOMER_ID", "CHANNEL_FAMILY_ID", "SERVER_ID", "CREATED", "MODIFIED") AS 
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
        and exists (
                select 1
                from
                    rhnChannelFamilyVirtSubLevel cfvsl,
                    rhnSGTypeVirtSubLevel sgtvsl,
                    rhnServerEntitlementView sev,
                    rhnVirtualInstance vi
                where
                    vi.virtual_system_id = rs.id
                    and vi.host_system_id = sev.server_id
                    and sev.label in ('virtualization_host',
                                      'virtualization_host_platform')
                    and sev.server_group_type_id = sgtvsl.server_group_type_id
                    and sgtvsl.virt_sub_level_id = cfvsl.virt_sub_level_id
                    and cfvsl.channel_family_id = rcf.id
                )
 
/
