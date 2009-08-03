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

create or replace view
rhnUserAvailableChannels
(
    	user_id,
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
	parent_or_self_id,
	end_of_life
)
as
select
     ct.user_id,
     ct.org_id,
     ct.id, 
     CT.depth, 
     CT.name, 
     CT.channel_arch_id, 
     CT.padded_name,
     (
     SELECT COUNT(1) 
       FROM rhnUserServerPerms USP
      WHERE USP.user_id = ct.user_id
        AND EXISTS (SELECT 1 FROM rhnServerChannel WHERE channel_id = ct.id AND server_id = USP.server_id)
     ),
     rhn_channel.available_chan_subscriptions(ct.id, ct.org_id),
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id,
     CT.end_of_life
from
     rhnUserChannelTreeView ct      
where rhn_channel.org_channel_setting(ct.id, ct.org_id ,'not_globally_subscribable') = 0 OR exists (
     						SELECT 1 from rhnChannelPermission per where per.channel_id = ct.id     
     						) 
                            OR (rhn_user.check_role(ct.user_id, 'org_admin') = 1 
                                OR rhn_user.check_role(ct.user_id, 'channel_admin') = 1)
;

--
--
-- Revision 1.8 2008/03/26 mmccune
-- bugzilla: 439023 - making sure org and channel admins can view the channels in their org
--
-- Revision 1.7	2007/10/25 jsherrill
-- bugzilla:172796 -- modified query to obey  user channel permissions in the 
--	rhnChannelPermission table if a channel is not globally subscribable
--
-- Revision 1.6  2004/04/15 16:04:21  pjones
-- bugzilla: none -- add deps, make rhnUserAvailableChannels show org_id
--
-- Revision 1.5  2004/04/15 15:47:46  pjones
-- bugzilla: none -- make rhnUserAvailableChannels suck way less
--
-- Revision 1.4  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
