-- $Id$
--
-- tricky view.  it explodes to a full cartesian product when
-- not queried via org_id, so DO NOT DO THAT :)

create or replace view
rhnAvailableChannels
(
    	org_id,
	channel_id,
	channel_depth,
	channel_name,
	channel_arch_id,
	padded_name,
	current_members,
	available_members,
        last_modified,
        channel_label,
	parent_or_self_label,
	parent_or_self_id 
)
as
select
     ct.org_id,
     ct.id, 
     CT.depth, 
     CT.name, 
     CT.channel_arch_id, 
     CT.padded_name,
     (SELECT COUNT(1) 
        FROM rhnServer S 
       WHERE S.org_id = ct.org_id 
         AND EXISTS (SELECT 1 FROM rhnServerChannel WHERE channel_id = ct.id AND server_id = S.id)),
     rhn_channel.available_chan_subscriptions(ct.id, ct.org_id),
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id
from
     rhnOrgChannelTreeView CT
/

--
-- $Log$
-- Revision 1.17  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
